import UIKit
import VNHandlers

internal class ProcessTargetService {

	private let deeplinkService: IOpenURLHandler
	private let application: UIApplication

	init(application: UIApplication, deeplinkService: IOpenURLHandler) {
		self.application = application
		self.deeplinkService = deeplinkService
	}

	func process(button: StoryButton) {
		if let urlString = button.urlString, let url = URL(string: urlString), self.application.canOpenURL(url) {
			self.application.open(url, options: [:], completionHandler: nil)
		} else if let deeplink = button.deeplinkString, let url = URL(string: deeplink) {
			_ = self.deeplinkService.application(self.application, open: url, options: [:])
		}
	}

}
