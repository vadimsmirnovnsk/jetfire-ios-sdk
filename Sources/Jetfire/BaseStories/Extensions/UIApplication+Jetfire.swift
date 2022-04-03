import UIKit

extension UIApplication {

	static var hasTopNotch: Bool { self.topNotchHeight > 24 }
	static var topNotchHeight: CGFloat { UIApplication.safeAreaInsets.top }
	static var bottomAreaHeight: CGFloat { UIApplication.safeAreaInsets.bottom }
	static var gradientOffset: CGFloat { return self.hasTopNotch ? 78 : 0 }

	static var safeAreaInsets: UIEdgeInsets {
		if #available(iOS 11.0,  *) {
			return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
		}
		return .zero
	}

	static var isWideScreenOrX: Bool {
		let widthPortrait = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
		let isWideScreen = widthPortrait > 375
		let isX = UIApplication.hasTopNotch
		return isWideScreen || isX
	}

	class func openSettings() {
		let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
		if UIApplication.shared.canOpenURL(settingsUrl) {
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(settingsUrl,
										  options: [:],
										  completionHandler: nil)
			} else {
				UIApplication.shared.openURL(settingsUrl)
			}
		}
	}

}
