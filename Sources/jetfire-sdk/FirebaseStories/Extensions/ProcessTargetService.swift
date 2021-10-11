import UIKit

public protocol IOpenURLHandler: AnyObject {

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool

}

internal class ProcessTargetService {

	var deeplinkService: IOpenURLHandler?
	private let application: UIApplication

	init(application: UIApplication) {
		self.application = application
	}

	func process(button: StoryButton) {
		if let urlString = button.urlString, let url = URL(string: urlString), self.application.canOpenURL(url) {
			self.application.open(url, options: [:], completionHandler: nil)
		} else if let deeplink = button.deeplinkString, let url = URL(string: deeplink) {
			_ = self.deeplinkService?.application(self.application, open: url, options: [:])
		}
	}

}
