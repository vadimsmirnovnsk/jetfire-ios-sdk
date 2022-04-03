import Foundation

@objc final class DownloadQueue: NSObject {

	enum State {
		case idle
		case start
		case pause
	}

	struct DownloadTask {
		let downloadable: IDownloadable
		let request: DownloadRequest
	}

	struct DownloadFinished {
		let downloadable: IDownloadable
		let error: Error?
	}

	let onFinish = Event<DownloadQueue?>()
	let api: IAPIService

	private(set) var state: State = .idle
	@objc dynamic private(set) var progress: Double = 0
	private(set) var bytes: Int64 = 0
	private(set) var totalBytes: Int64 = 0

	private var currentTasks = [UUID: DownloadTask]()
	let allItems: [IDownloadable]
	private var itemsToDownload: [IDownloadable]
	private var itemsToDownloadQueue = [IDownloadable]()
	private let maximumDownloadsCount = 2
	private var cancelGroup: DispatchGroup?
	private(set) var startDate: Date?
	private(set) var lastError: Error?

	var isCompleted: Bool { self.allItems.isDownloaded }
	var downloadTime: TimeInterval {
		guard let startDate = self.startDate else { return -1 }
		return Date().timeIntervalSince(startDate)
	}
	var isStarted: Bool {
		return self.state == .start
	}
	var itemsToDownloadCount: Int {
		return self.itemsToDownload.count
	}

	func resume() {
		if self.state == .pause {
			self.start()
		}
	}

	init(api: IAPIService, items: [IDownloadable]) {
		self.api = api
		self.itemsToDownload = []
		let all = items
		var allUniqueItems = [IDownloadable]()
		for item in all {
			if allUniqueItems.first(where: { $0.sourceURL == item.sourceURL }) == nil {
				allUniqueItems.append(item)
			}
		}
		self.allItems = allUniqueItems
		super.init()
	}

	func start() {
		guard self.state != .start else { return }

		self.itemsToDownload = self.allItems.filter { !$0.isDownloaded }
		self.itemsToDownloadQueue = self.itemsToDownload
		self.startDate = Date()
		self.state = .start
		self.lastError = nil
		self.bytes = 0
		self.progress = 0
		self.totalBytes = self.bytes

//		log.info("⏬ Start download queue, items:\n\(self.itemsToDownload.logText)") // >>> 123
		print("⏬ Start download queue, items:\n\(self.itemsToDownload.logText)")
		self.downloadNext()
	}

	private var downloadedItemsCount: Int {
		self.itemsToDownload.filter { $0.isDownloaded }.count
	}

	private func downloadNext() {
		if self.itemsToDownloadQueue.isEmpty {
			if self.currentTasks.isEmpty {
				self.state = .idle
				self.onFinish.raise(self)
//				log.info("✅ Finish download") /// >>> 123
				print("✅ Finish download")
			}
		} else if self.currentTasks.count < self.maximumDownloadsCount {
			let next = self.itemsToDownloadQueue.removeFirst()
			self.downloadItem(next)
			self.downloadNext()
		}
	}

	private func downloadItem(_ item: IDownloadable) {
		if item.isDownloaded {
			self.downloadNext()
			return
		}
//		log.info("⏬ Start download: \(item.sourceURL) to \(item.downloadUrl.lastPathComponent)") /// >>> 123
		print("⏬ Start download: \(item.sourceURL) to \(item.downloadUrl.lastPathComponent)")
		let request = self.api.download(item.sourceURL, toUrl: item.downloadUrl)
		request.downloadProgress { [weak self] (p) in
			self?.updateProgress()
		}
		request.response { [weak self, weak request] (response) in
			guard let this = self, let request = request else { return }
			// Обрабатываем cancel
			this.onCurrentDownloadCompleted(request)
		}
		self.currentTasks[request.id] = DownloadTask(downloadable: item, request: request)
	}

	func updateProgress() {
		guard self.itemsToDownloadCount > 0 else { return }
		var progress: Double = 0
		var bytes: Int64 = 0
		self.currentTasks.forEach { (_, task) in
			let p = task.request.downloadProgress
			progress += p.fractionCompleted
			bytes += Int64(p.fractionCompleted * Double(p.totalUnitCount))
		}
		/// прогресс это количество завешенных тасок и текущий прогресс текущих тасок
		let finishedTasksCount = self.itemsToDownloadCount - self.itemsToDownloadQueue.count - self.currentTasks.count
		self.progress = (Double(finishedTasksCount) + progress) / Double(self.itemsToDownloadCount)
		self.bytes = self.totalBytes + bytes
	}

	private func onCurrentDownloadCompleted(_ request: DownloadRequest) {
		if let url = request.request?.url, let httpCode = request.response?.statusCode, httpCode == 200 {
			self.store(resumeData: request.resumeData, for: url)
		}

		if let task = self.currentTasks.removeValue(forKey: request.id) {
			let finished = DownloadFinished(downloadable: task.downloadable, error: request.error)
			_ = finished

			let name = task.downloadable.downloadUrl.lastPathComponent
			if let error = request.error {
//				log.error("⏹ Reqest error \(name): \(error.analCode) \(error.localizedDescription)") // >>> 123
				print("⏹ Reqest error \(name): \(error.analyticsCode) \(error.localizedDescription)")
			} else if let httpCode = request.response?.statusCode, httpCode != 200 {
//				log.error("⏹ Reqest http error \(name): \(httpCode)") // >>> 123
				print("⏹ Reqest http error \(name): \(httpCode)")
			} else {
//				log.info("🏁 Reqest finished \(name)") // >>> 123
				print("🏁 Reqest finished \(name)")
			}
		} else {
//			Anal.assert("Completed task come from nowhere with url: \(request.request?.url?.absoluteString ?? "")")
		}
		self.totalBytes += request.downloadProgress.totalUnitCount

		if request.isCancelled {
			print("⏸ Reqest cancelled") // >>> 123
//			log.info("⏸ Reqest cancelled")
			self.cancelGroup?.leave()
		} else {
			self.downloadNext()
		}

//		if let error = request.error {
//			Anal.track(.error_client, params: [
//				.error : error.analDescription,
//				.error_code : error.analCode
//			])
//		}
		if request.error != nil {
			self.lastError = request.error
		}
	}

	func resumeDataPath(for url: URL) -> URL {
		let path = FileManager.libraryPath(forFileName: url.absoluteString.SHA1String)!
		return path
	}

	private func store(resumeData: Data?, for url: URL) {
//		let path = self.resumeDataPath(for: url)
//		do {
//			if let resumeData = resumeData {
//				try resumeData.write(to: path, options: [.atomic])
//			} else {
//				try FileManager.default.removeItem(at: path)
//			}
//		} catch {}
	}

	/// если resumable == true мы не нотифицируем что все закончилось, а как бы ставим на паузу
	func cancel(terminate: Bool, with completion: @escaping VoidBlock) {
		guard self.state == .start else { return }
		if terminate {
			self.state = .idle
		} else {
			self.state = .pause
		}

		let cancelGroup = DispatchGroup()
		let currentRequests = self.currentTasks
		currentRequests.forEach {
			cancelGroup.enter()
			$0.value.request.cancel()
		}
		cancelGroup.notify(queue: .main) {
			self.currentTasks = [:]
			self.itemsToDownloadQueue = []
			self.itemsToDownload = []
			completion()
		}
		self.cancelGroup = cancelGroup

		if terminate {
			self.onFinish.raise(nil)
		}
	}

}

extension Array where Element == IDownloadable {

	var logText: String {
		self.map { "\($0.downloadUrl.lastPathComponent)|\($0.isDownloaded)" }.joined(separator: "\n")
	}

}
