import VNBase
import UIKit

extension NavigationBarStyle {

	@objc public static let lightTransparent = NavigationBarStyle(
		tintColor: .white,
		barTintColor: .white,
		translucent: true,
		titleTextAttributes: [ .foregroundColor : UIColor.white, .font : UIFont.systemFont(ofSize: 14) ],
		backgroundImage: UIImage(),
		shadowImage: UIImage()
	)

}
