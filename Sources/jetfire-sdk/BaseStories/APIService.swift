import Alamofire
import Foundation

public protocol IAPIService: AnyObject {

	func download(_ url: URL, toUrl: URL) -> DownloadRequest

}

//internal typealias FeaturingDataBlock = (FeaturingData) -> Void
//internal protocol IFeaturingAPI: AnyObject {
//	/// Featuring
//	func featchFeaturingRules(for user: String, completion: @escaping FeaturingDataBlock)
//}

class APIService: IAPIService {

	public let downloadManager: Session

	init() {
		let downloadConfiguration = URLSessionConfiguration.default
		downloadConfiguration.timeoutIntervalForResource = 60
		downloadConfiguration.timeoutIntervalForRequest = 60
		self.downloadManager = Session(configuration: downloadConfiguration)
	}

	func download(_ url: URL, toUrl: URL) -> DownloadRequest {
		let req = self.downloadManager.download(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, to:  { (url, response) -> (destinationURL: URL, options: DownloadRequest.Options) in
			return (toUrl, [ .createIntermediateDirectories, .removePreviousFile ])
		})
		return req
	}

}

//extension APIService: IFeaturingAPI {

//	func featchFeaturingRules(for user: String, completion: @escaping FeaturingDataBlock) {
//		completion(.demo)
//	}

//}
