import UIKit
import VNBase
import VNEssential
import VNHandlers

/// Класс, который конфигурирует доступные типы снапов и сториз — пока здесь только InfoSnap.

public struct SnapStyle: IPopulatable {

	public typealias T = SnapStyle

	/// Стиль Title (к нему будет применяться цвет из данных снапа)
	public var titleStyle: TextStyle
	/// Стиль Subtitle (но к нему будет применяться 50% альфа и цвет из снапа)
	public var subtitleStyle: TextStyle
	/// Стиль Message (к нему будет применяться цвет из данных снапа)
	public var messageStyle: TextStyle
	/// Инсеты контейнера с текстами и кнопкой относительно краёв снапа
	public var containerInsets: UIEdgeInsets
	/// Инсет между тайтлом/сабтайтлом и текстом
	public var messageSpacing: CGFloat
	/// Инсет между текстом и кнопкой
	public var buttonSpacing: CGFloat
	/// Стиль кнопки
	public var buttonStyle: SnapButtonStyle
	/// Стиль прогресс бара
	public var barStyle: SnapProgressBarStyle
	/// Стиль кнопки закрыть
	public var closeButtonStyle: SnapCloseButtonStyle

	public static func delo() -> SnapStyle {
		return SnapStyle(
			titleStyle: TextStyle.storyTitleBlack(),
			subtitleStyle: TextStyle.system17White,
			messageStyle: TextStyle.system17White,
			containerInsets: UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16),
			messageSpacing: 16,
			buttonSpacing: 24,
			buttonStyle: .delo(),
			barStyle: .delo(),
			closeButtonStyle: .delo()
		)
	}

}

public struct SnapButtonStyle: IPopulatable {

	public typealias T = SnapButtonStyle

	public enum Behavior {
		case fullscreen
		case part
	}

	/// Цвет кнопки
	public var bgColor: UIColor
	/// Цвет кнопки в нажатом состоянии
	public var highlightedBgColor: UIColor
	/// Цвет заголовка кнопки
	public var titleStyle: TextStyle
	/// Инсеты заголовка относительно краёв кнопки
	public var titleInsets: UIEdgeInsets
	/// Высота кнопки
	public var height: CGFloat
	/// Радиус скругления кнопки
	public var cornerRadius: CGFloat
	/// Как выглядит кнопка — на весь экран или занимает только часть слева
	public var behavior: SnapButtonStyle.Behavior
	/// Предпочитаемая ширина кнопки, если behavior = .part
	public var preferredWidth: CGFloat
	/// Добавлять ли тень для кнопки
	public var addShadow: Bool

	public static func delo() -> SnapButtonStyle {
		return SnapButtonStyle(
			bgColor: .deloButtonBlue,
			highlightedBgColor: .deloButtonHighlightedBlue,
			titleStyle: TextStyle.systemSemiBold16White,
			titleInsets: UIEdgeInsets(top: 2, left: 12, bottom: 0, right: 12),
			height: 50,
			cornerRadius: 12,
			behavior: .fullscreen,
			preferredWidth: 256,
			addShadow: true
		)
	}

}

public struct SnapProgressBarStyle: IPopulatable {

	public typealias T = SnapProgressBarStyle

	/// Цвет заполнения прогресс бара
	public var topColor: UIColor
	/// Цвет подложки
	public var bottomColor: UIColor
	/// Расстояние между сегментами
	public var padding: CGFloat
	/// Высота сегментов
	public var height: CGFloat
	/// Инсеты от левого, верхнего и правого края экрана
	public var insets: UIEdgeInsets

	public static func delo() -> SnapProgressBarStyle {
		return SnapProgressBarStyle(
			topColor: .white,
			bottomColor: UIColor.white.withAlphaComponent(0.17),
			padding: 4,
			height: 4,
			insets: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
		)
	}

}

public struct SnapCloseButtonStyle: IPopulatable {

	public typealias T = SnapCloseButtonStyle

	/// Картинка кнопки
	public var image: UIImage?
	/// Картинка кнопки в нажатом состоянии
	public var highlightedImage: UIImage?
	/// Инсеты кнопки от верхнего и правого края
	public var insets: UIEdgeInsets

	public static func delo() -> SnapCloseButtonStyle {
		return SnapCloseButtonStyle(
			image: nil, // UIImage.rectImage(colored: .red, size: CGSize(width: 48, height: 48)),
			highlightedImage: nil, // UIImage.rectImage(colored: .blue, size: CGSize(width: 48, height: 48)),
			insets: UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 16)
		)
	}

}
