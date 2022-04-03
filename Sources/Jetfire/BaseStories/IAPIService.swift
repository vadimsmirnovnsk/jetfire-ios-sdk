import Foundation

public protocol IAPIService: AnyObject {

	func download(_ url: URL, toUrl: URL) -> DownloadRequest

}
