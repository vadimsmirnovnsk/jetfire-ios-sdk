import UIKit
import VNEssential

public struct ToastStyle: IPopulatable {

	public typealias T = ToastStyle

	public var styleInset: UIEdgeInsets
	public var cornerRadius: CGFloat
	public var textStyle: TextStyle
	public var textInset: UIEdgeInsets
	public var numberOfLines: Int
	public var textAlignment: NSTextAlignment
	public var hasShadow: Bool
	public var animation: ToastAnimation
	public var image: ToastImage
	public var autoHideTime: TimeInterval

	static func delo() -> ToastStyle {
		ToastStyle(
			styleInset: UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 20),
			cornerRadius: 16,
			textStyle: .system16White,
			textInset: UIEdgeInsets(top: 12, left: 16, bottom: 14, right: 16),
			numberOfLines: 0,
			textAlignment: .left,
			hasShadow: false,
			animation: .delo(),
			image: .delo(),
			autoHideTime: 5
		)
	}

}

public struct ToastAnimation: IPopulatable {

	public typealias T = ToastAnimation

	public var duration: TimeInterval
	public var delay: TimeInterval
	public var usingSpringWithDamping: CGFloat
	public var initialSpringVelocity: CGFloat

	static func delo() -> ToastAnimation {
		ToastAnimation(
			duration: 0.37,
			delay: 0.0,
			usingSpringWithDamping: 0.7,
			initialSpringVelocity: 0.3
		)
	}

}

public struct ToastImage: IPopulatable {

	public typealias T = ToastImage

	public var size: CGSize
	public var cornerRadius: CGFloat
	/// Инсет вокруг картинки — топ, право и низ от края. Лево от текста
	public var inset: UIEdgeInsets

	public init(
		size: CGSize,
		cornerRadius: CGFloat,
		inset: UIEdgeInsets
	) {
		self.size = size
		self.cornerRadius = cornerRadius
		self.inset = inset
	}

	static func delo() -> ToastImage {
		ToastImage(
			size: CGSize(width: 40, height: 40),
			cornerRadius: 8,
			inset: UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 16))
	}

}
