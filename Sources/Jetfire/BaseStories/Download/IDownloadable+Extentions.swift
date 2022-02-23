import Foundation

enum FileType {
	case audio
	case video
	case image

	var ext: String {
		switch self {
			case .audio: return "m4a"
			case .video: return "mp4"
			case .image: return "jpg"
		}
	}

	var folder: URL {
		switch self {
			case .audio: return URL(fileURLWithPath: FileManager.cachesDirectory()).appendingPathComponent("Audio")
			case .video: return URL(fileURLWithPath: FileManager.cachesDirectory()).appendingPathComponent("Video")
			case .image: return URL(fileURLWithPath: FileManager.cachesDirectory()).appendingPathComponent("Images")
		}
	}

}

protocol IDownloadable {

	var urlString: String { get }
	var fileType: FileType { get }
}

extension IDownloadable {

	var sourceURL: URL {
		return URL(string: self.urlString)!
//		let urlString = self.urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//		let url = URL(string: urlString)!
//		return url
	}

	var isDownloaded: Bool {
		return FileManager.default.fileExists(atPath: self.playURL.path)
	}
	var fileSize: Int64 {
		if let resources = try? self.playURL.resourceValues(forKeys:[.fileSizeKey]),
			let fileSize = resources.fileSize {
			return Int64(fileSize)
		}
		return 0
	}

	/// URL скачанного объекта
	var downloadUrl: URL {
		return self.fileType.folder.appendingPathComponent(self.fileName)
	}

	private var fileName: String {
		let name = (self.urlString as NSString).lastPathComponent.MD5String
		let fileName = "\(name).\(self.fileType.ext)"
		return fileName
	}

	var legacy2URL: URL {
		return FileManager.libraryPath(forFileName: self.fileName)!
	}

	var playURL: URL {
		let last = (self.urlString as NSString).lastPathComponent

		if let bundleUrl = Bundle.main.url(forResource: last, withExtension: nil),
			FileManager.default.fileExists(atPath: bundleUrl.path) {
			return bundleUrl
		}

		return self.downloadUrl
	}

}

extension Array where Element == IDownloadable {

	var isDownloaded: Bool {
		self.first(where: { !$0.isDownloaded }) == nil
	}

}
