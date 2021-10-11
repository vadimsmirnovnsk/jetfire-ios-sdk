import VNBase
import UIKit

extension NavigationBarStyle {

	@objc public static let lightTransparent = NavigationBarStyle(
		tintColor: .white,
		barTintColor: .white,
		translucent: true,
		titleTextAttributes: StoriesConfig.standard.navigationBarTextAttribbutes,
		backgroundImage: UIImage(),
		shadowImage: UIImage()
	)

}
