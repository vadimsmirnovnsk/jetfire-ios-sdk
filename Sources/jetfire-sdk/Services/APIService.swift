import Alamofire
import Foundation
import SwiftProtobuf

final class TimeoutRequestInterceptor: RequestInterceptor {

	private let timeoutInterval: TimeInterval

	init(timeoutInterval: TimeInterval) {
		self.timeoutInterval = timeoutInterval
	}

	func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (AFResult<URLRequest>) -> Void) {
		var req = urlRequest
		req.timeoutInterval = self.timeoutInterval
		completion(.success(req))
	}
}


class APIService: IAPIService {

	public let manager: Session
	public let downloadManager: Session

	private var baseURLString: String = ""
	private var headers: [String : String]
	private let bearer: String
	private let userSessionService: UserSessionService

	private var localTime: String {
		DateFormatter.preferencesDateFormatter.string(from: Date.now)
	}

	init(bearer: String, userSessionService: UserSessionService) {
		self.bearer = bearer
		self.userSessionService = userSessionService

		let headers: [String : String] = [
			"Authorization" : "Bearer \(bearer)",
		]
		self.headers = headers

		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = Constants.timeoutIntervalForRequest
		configuration.timeoutIntervalForResource = Constants.timeoutIntervalForRequest
		configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		self.manager = Session(configuration: configuration)

		let downloadConfiguration = URLSessionConfiguration.default
		downloadConfiguration.timeoutIntervalForResource = 600
		downloadConfiguration.timeoutIntervalForRequest = 180
		self.downloadManager = Session(configuration: downloadConfiguration)
	}

	func configure(
		forBaseUrlString urlString: String?,
		overrideHeaders: [String: String]
	) {
		if let urlString = urlString {
			self.baseURLString = urlString
		}
		overrideHeaders.forEach { (key, value) in
			self.headers[key] = value
		}

		#if DEBUG
//		if TestConfig.loginAsUser {
//			self.headers["X-User-Idfa"] = "D22B16CB-9E77-4800-A898-0693CE895BBF"
//			self.headers["X-User-Session-UUID"] = "C7797D0F-A6F9-4A07-B06D-F6EAEE6E556B"
//			self.headers["X-User-UUID"] = "D22B16CB-9E77-4800-A898-0693CE895BBF"
//			self.headers["X-Device-Id"] = "001D2E5D-1401-4AA6-B15F-A263AA134AE7"
//			self.headers["X-User-Token"] = "44323242313643422d394537372d343830302d413839382d303639334345383935424246"
//		}
		#endif
	}

	fileprivate func unwrappedProtoRequest<T: Message>(
		httpMethod: HTTPMethod,
		method: String,
		protoObject: SwiftProtobuf.Message?,
		queue: DispatchQueue = .main,
		timeoutInterval: TimeInterval = Constants.timeoutIntervalForRequest,
		shouldLog: Bool = true,
		callback: @escaping ((Result<T, Error>) -> Void)
	) {
		self.protoRequest(
			httpMethod: httpMethod,
			method: method,
			protoObject: protoObject,
			queue: queue,
			timeoutInterval: timeoutInterval,
			shouldLog: shouldLog
		) { (response) in
			DispatchQueue.global().async {
				let r = response.unwrapProto(to: T.self)
				queue.async {
					callback(r)
				}
			}
		}
	}

	fileprivate func protoRequest(
		httpMethod: HTTPMethod,
		method: String,
		protoObject: SwiftProtobuf.Message?,
		queue: DispatchQueue = .main,
		timeoutInterval: TimeInterval = Constants.timeoutIntervalForRequest,
		shouldLog: Bool = true,
		callback: @escaping ((Result<Data, Error>) -> Void)
	) {
		do {
			let data = try protoObject?.serializedData()
			self.request(
				httpMethod: httpMethod,
				method: method,
				params: nil,
				body: data,
				queue: queue,
				debugRequest: protoObject?.debugDescription ?? "",
				timeoutInterval: timeoutInterval,
				shouldLog: shouldLog,
				callback: callback
			)
		} catch {
			print("Serialise error: \(error)")
			queue.async {
				callback(.failure(JetfireError.apiProtoWrapError))
			}
		}
	}

	func download(_ url: URL, toUrl: URL) -> DownloadRequest {
		let req = self.downloadManager.download(
			url,
			method: .get,
			parameters: nil,
			encoding: URLEncoding.default,
			headers: nil, to:  { (_, _) -> (destinationURL: URL, options: DownloadRequest.Options) in
				return (toUrl, [ .createIntermediateDirectories, .removePreviousFile ])
			})
		return req
	}

	func resumeDownload(with data: Data) -> DownloadRequest {
		return self.downloadManager.download(resumingWith: data)
	}

	func unwrappedRequest<T: Message>(
		httpMethod: HTTPMethod,
		method: String,
		params: [String : Any]? = nil,
		body: Data? = nil,
		queue: DispatchQueue = .main,
		timeoutInterval: TimeInterval = Constants.timeoutIntervalForRequest,
		shouldLog: Bool = true,
		callback: @escaping ((Result<T, Error>) -> Void)
	) {
		self.request(
			httpMethod: httpMethod,
			method: method,
			params: params,
			body: body,
			queue: queue,
			timeoutInterval: timeoutInterval,
			shouldLog: shouldLog
		) { (response) in
			DispatchQueue.global().async {
				let r = response.unwrapProto(to: T.self)
				queue.async {
					callback(r)
				}
			}
		}
	}

	fileprivate func request(
		httpMethod: HTTPMethod,
		method: String,
		params: [String : Any]?,
		body: Data? = nil,
		queue: DispatchQueue = .main,
		debugRequest: String = "",
		timeoutInterval: TimeInterval = Constants.timeoutIntervalForRequest,
		shouldLog: Bool = true,
		callback: @escaping ((Result<Data, Error>) -> Void)
	) {
		let urlString = self.baseURLString + method
		var reqHeaders = self.headers
		reqHeaders["X-User-Local-Time"] = self.localTime

		if httpMethod == .post {
			reqHeaders["Content-Type"] = "application/json"
		}

		if shouldLog {
			#if DEBUG
			print("Will perform \(httpMethod) \(urlString), params: \(String(describing: params)), request: \(debugRequest)")
			#endif
		}

		// Эта грязь для пуш-токенов
		var request: DataRequest
		let interceptor = TimeoutRequestInterceptor(timeoutInterval: timeoutInterval)
		if let body = body {
			var req = URLRequest(url: URL(string: urlString)!)
			req.httpMethod = httpMethod.rawValue
			req.httpBody = body
			if httpMethod == .post {
				reqHeaders["Content-Type"] = "application/grpc+proto"
			}
			for (key, value) in reqHeaders {
				req.setValue(value, forHTTPHeaderField: key)
			}
			request = self.manager.request(req, interceptor: interceptor)
		} else {
			let encoding: ParameterEncoding = httpMethod == .post
				? JSONEncoding.default
				: URLEncoding.default
			request = self.manager.request(
				urlString,
				method: httpMethod,
				parameters: params,
				encoding: encoding,
				headers: HTTPHeaders(reqHeaders),
				interceptor: interceptor
			)
		}
		let startDate = Date()
		request.responseData(completionHandler: { response in
			let result: Result<Data, Error>

			let duration = Date().timeIntervalSince(startDate)
			let durationsMessage = "Request duration \(duration) for \(urlString)"
			if duration > 1 {
				#if DEBUG
				print(durationsMessage)
				#endif
			} else {
				print(durationsMessage)
			}

			if let data = response.data, let code = response.response?.statusCode {
				if case 200..<310 = code {
					// Хороший результат с сервера
					if shouldLog {
						#if DEBUG
						print("Did successfully complete \(httpMethod) \(urlString), params: \(String(describing: params))")
						#endif
					}
					result = .success(data)
				} else {
					// Ошибка сервера
					let errorResult: Result<Data, Error> = .success(data)
					let errorResponse = errorResult.unwrapProto(to: JetFireErrorResponse.self)

					switch errorResponse {
						case .success(let errorModel):
							result = .failure(errorModel)
							print("Did receive error: \(errorModel) for \(httpMethod) \(urlString), params: \(String(describing: params)), DebugRequest: \(debugRequest)")
//							Anal.track(.error_backend, params: [
//								.error : errorModel.message,
//								.message: errorModel.systemMessage,
//								.error_code: Int(errorModel.code),
//								.type: errorModel.type,
//							])
						case .failure:
							result = errorResult
							let text = String(data: data, encoding: .utf8) ?? ""
							let message = "Did receive unwrapped error code: \(code) result: \(errorResult) for \(httpMethod) \(urlString), params: \(String(describing: params)), string: \(text) DebugRequest: \(debugRequest)"
							print(message)
//							Anal.track(.error_backend, params: [
//								.error : message,
//								.error_code : code,
//							])
					}
				}
			} else if let error = response.error {
				// Ошибки сети
				print("Did receive error: \(error) for \(httpMethod) \(urlString), params: \(String(describing: params))")
				result = .failure(JetfireError.apiGeneral)

//				Anal.track(.error_client, params: [
//					.error : error.analDescription,
//					.error_code : error.analCode,
//					.value: urlString,
//				])
			} else {
				// Прочие ошибки
				print("Did receive nil data response for \(httpMethod) \(urlString), params: \(String(describing: params))")
				result = .failure(JetfireError.apiNilDataError)

//				Anal.track(.error_client, params: [
//					.error : MmplzError.apiNilDataError.analDescription,
//					.value: urlString,
//				])
			}

			#if DEBUG
			if let data = response.data {
				let str = String(data: data, encoding: .utf8) ?? ""
				let code = response.response?.statusCode ?? -1
				print("Did receive code: \(code) result: \(str) for \(httpMethod) \(urlString), params: \(String(describing: params))")
			}
			#endif

			queue.async {
				callback(result)
			}
		})
	}

}

extension APIService: IFeaturingAPI { // + Jetfire API

	func fetchCampaigns(completion: @escaping (Result<JetFireListCampaignsResponse, Error>) -> Void) {
		let req = JetFireListCampaignsRequest.with {
			$0.user = self.userSessionService.user()
			$0.session = self.userSessionService.session()
		}
		let method = "campaigns"
        self.unwrappedProtoRequest(
            httpMethod: .post,
            method: method,
            protoObject: req,
            queue: .jetfire,
            callback: completion
        )
	}

	func sync(events: [JetFireEvent], completion: @escaping (Result<JetFireOkResponse, Error>) -> Void) {
		let req = JetFireRegisterEventsRequest.with {
			$0.user = self.userSessionService.requestUser()
			$0.session = self.userSessionService.requestSession()
			$0.events = events
		}
		let method = "sink"
		self.unwrappedProtoRequest(httpMethod: .post, method: method, protoObject: req, callback: completion)
	}

}
