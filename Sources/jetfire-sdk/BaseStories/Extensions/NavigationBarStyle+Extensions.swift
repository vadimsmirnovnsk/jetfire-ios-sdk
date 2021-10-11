import VNBase
import UIKit

extension NavigationBarStyle {

	@objc public static let lightTransparent = NavigationBarStyle(
		tintColor: .white,
		barTintColor: .white,
		translucent: true,
		titleTextAttributes: Jetfire.standard.storiesConfig.navigationBarTextAttribbutes,
		backgroundImage: UIImage(),
		shadowImage: UIImage()
	)

}
