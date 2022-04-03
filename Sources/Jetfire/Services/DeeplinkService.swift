import UIKit

// Класс для обработки всех диплинков, поддерживаемых Jetfire
protocol ICanShowContent: AnyObject {

	func showStory(with id: String)
	func showTrigger(with id: String)

}

// DeeplinkService нужен для двух случаев:
// 1. Чтобы создать сториз и прокинуть диплинк на неё, например, в пуш нотификацию, которую уже сам менеджер как-то доставит пользователю. Или даже в QR-код
// 2. Чтобы по диплинку тестировать, как выглядят на устройстве сториз и тосты — типа сканишь диплинк, выскакивает тост или отображается нужная сториз независимо от правил её показа
// 3. Подкладывания нужных настроек sdk в боевое приложение
// Но прямо сейчас не используется никак

class DeeplinkService: IOpenURLHandler {

	static private let jetfireHost = "jf"

	weak var delegate: ICanShowContent?

	private let plistSettingsService: IPlistSettingsService

	init(plistSettingsService: IPlistSettingsService) {
		self.plistSettingsService = plistSettingsService
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
		guard components.host == DeeplinkService.jetfireHost else { return false }

		var isHandled = false
//		var headers = [String: String]()
//		if let headersString = components.query(with: "headers") {
//			headers = headersString.urlHeaders()
//			isHandled = true
//		}
//		let saveBaseUrl = components.query(with: "save_baseurl")?.boolValue ?? false
//		if !saveBaseUrl {
//			self.ud.baseURL = nil
//		}

		let baseURL = components.query(with: "api_url")
		if baseURL != nil {
			isHandled = true
		}
//		self.apiService.configure(
//			forBaseUrlString: baseURL,
//			overrideHeaders: headers
//		)
//		if saveBaseUrl {
//			self.ud.baseURL = baseURL
//		}
		if let storyId = components.query(with: "show_story") {
			self.delegate?.showStory(with: storyId)
			isHandled = true
		}
		if let triggerId = components.query(with: "show_trigger") {
			self.delegate?.showTrigger(with: triggerId)
			isHandled = true
		}

//		if let skipCount = components.query(with: "skip_count") {
//			Constants.skipExerciseCount = Int(skipCount)
//			isHandled = true
//		}
		if components.query(with: "debug_log") != nil {
//			Logger.enableDebugLogger()
			isHandled = true
		}
		if components.query(with: "cheat_mode") != nil {
//			Constants.cheatMode = true
			isHandled = true
		}
		if components.query(with: "show_close_button") != nil {
//			Constants.showPaywallCloseButton = true
			isHandled = true
		}
		if components.query(with: "can_start_program_without_payment") != nil {
//			Constants.canStartProgramWithoutPayment = true
			isHandled = true
		}
		if components.query(with: "send_message_to_production") != nil {
//			Bundle.sendMessageToProduction = true
			isHandled = true
		}
		if components.query(with: "emulate_cancel_subscription") != nil {
//			self.apiService.cancelSubscription()
			isHandled = true
		}
//		if let style = UIUserInterfaceStyle(string: components.query(with: "user_interface_style")) {
//			self.interfaceStyleService.updateUserInterfaceStyle(style)
//			isHandled = true
//		}
		return isHandled
	}
	
}

extension UIUserInterfaceStyle {
	init?(string: String?) {
		guard let string = string else { return nil }
		switch string {
			case "dark":
				self = .dark
			case "light":
				self = .light
			default:
				return nil
		}
	}
}

extension URLComponents {

	func query(with name: String) -> String? {
		return self.queryItems?.first(where: { (item) -> Bool in
			return item.name == name
		})?.value
	}

}

extension String {

	func urlHeaders() -> [String: String] {
		let keyvalues = self.components(separatedBy: ";")
		var headers = [String: String]()
		for keyvalueString in keyvalues {
			let keyvalue = keyvalueString.components(separatedBy: ":")
			if keyvalue.count == 2 {
				headers[keyvalue[0]] = keyvalue[1]
			}
		}
		return headers
	}

}
