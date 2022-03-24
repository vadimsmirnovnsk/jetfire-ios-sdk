import UIKit
import VNBase
import VNEssential
import VNHandlers

/// Класс, который конфигурирует доступные типы снапов и сториз — пока здесь только InfoSnap.

public struct SnapStyle: IPopulatable {

	public typealias T = SnapStyle

	public var titleStyle: TextStyle
	public var subtitleStyle: TextStyle
	public var messageStyle: TextStyle
	public var containerInsets: UIEdgeInsets
	/// Инсет между тайтлом/сабтайтлом и текстом
	public var messageSpacing: CGFloat
	/// Инсет между текстом и кнопкой
	public var buttonSpacing: CGFloat
	public var buttonStyle: SnapButtonStyle
	public var barStyle: SnapProgressBarStyle

	public static func delo() -> SnapStyle {
		return SnapStyle(
			titleStyle: TextStyle.storyTitleBlack(),
			subtitleStyle: TextStyle.system17White,
			messageStyle: TextStyle.system17White,
			containerInsets: UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16),
			messageSpacing: 16,
			buttonSpacing: 24,
			buttonStyle: .delo(),
			barStyle: .delo()
		)
	}

}

public struct SnapButtonStyle: IPopulatable {

	public typealias T = SnapButtonStyle

	public var bgColor: UIColor
	public var titleStyle: TextStyle
	public var titleInsets: UIEdgeInsets
	public var height: CGFloat
	public var cornerRadius: CGFloat
	public var preferredWidth: CGFloat
	public var addShadow: Bool

	public static func delo() -> SnapButtonStyle {
		return SnapButtonStyle(
			bgColor: .deloButtonBlue,
			titleStyle: TextStyle.systemSemiBold16White,
			titleInsets: UIEdgeInsets(top: 2, left: 12, bottom: 0, right: 12),
			height: 50,
			cornerRadius: 12,
			preferredWidth: 256,
			addShadow: true
		)
	}

}

public struct SnapProgressBarStyle: IPopulatable {

	public typealias T = SnapProgressBarStyle

	public var topColor: UIColor
	public var bottomColor: UIColor
	public var padding: CGFloat
	public var height: CGFloat
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
