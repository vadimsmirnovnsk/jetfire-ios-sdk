import UIKit
import Jetfire

extension TextStyle {

	static let system13GraffitBlack = TextStyle(font: .systemFont(ofSize: 13), color: .graffitBlack, interLetterSpacing: 0)

	// Firebase Stories
	static func storyTitleBlack() -> TextStyle {
		return .systemSemiBold24Black
//		return UIScreen.main.isSmall
//			? .systemSemiBold24Black
//			: .systemSemiBold31Black
	}
	static let systemSemiBold31Black = TextStyle(font: .systemFont(ofSize: 31, weight: .semibold), color: .black, interLetterSpacing: 0, lineHeight: 32)
	static let systemSemiBold24Black = TextStyle(font: .systemFont(ofSize: 24, weight: .semibold), color: .black, interLetterSpacing: 0, lineHeight: 25)
	static let system17White = TextStyle(font: .systemFont(ofSize: 17, weight: .regular), color: .white, interLetterSpacing: 0, lineHeight: 22)
	static let systemSemiBold19Black = TextStyle(font: .systemFont(ofSize: 19, weight: .semibold), color: .black, interLetterSpacing: 0, lineHeight: 20)

}
