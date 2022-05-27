import UIKit
import JetfireVNEssential

public struct ToastStyle: IPopulatable {

	public typealias T = ToastStyle

	/// Инсет всего тоста относительно краёв экрана
	public var styleInset: UIEdgeInsets
	/// Радиус скругления углов тоста
	public var cornerRadius: CGFloat
	/// Стиль текста
	public var textStyle: TextStyle
	/// Инсет текста относительно краёв тоста
	public var textInset: UIEdgeInsets
	/// Максимальное количество строк в тосте
	public var numberOfLines: Int
	/// Без комментариев)
	public var textAlignment: NSTextAlignment
	/// Есть ли тень от тоста на экране
	public var hasShadow: Bool
	/// Параметры анимации, с которой тост выпадывает на экран
	public var animation: ToastAnimation
	/// Параметры положения картинки справа сверху на тосте
	public var image: ToastImage
	/// Количество времени перед скрытием тоста, если выбран стиль dissmissable
	public var autoHideTime: TimeInterval

	static func delo() -> ToastStyle {
		ToastStyle(
			styleInset: UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12),
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
			duration: 0.4,
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
