import UIKit

public extension UIView {

	static func stackSpacing(with height: CGFloat) -> UIView {
		let v = UIView()
		v.snp.makeConstraints { make in make.height.equalTo(height) }
		return v
	}

	static func colored(_ color: UIColor) -> UIView {
		let view = UIView()
		view.backgroundColor = color
		return view
	}

}
