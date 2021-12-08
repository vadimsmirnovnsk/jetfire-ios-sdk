import VNBase
import UIKit

public struct ColorGradient {

	public let from: UIColor
	public let to: UIColor
	public init(from: UIColor, to: UIColor) {
		self.from = from
		self.to = to
	}

}

// MARK: - Gradients

public extension ColorGradient {

	static let CommonOrange = ColorGradient(from: .CommonOrange, to: #colorLiteral(red: 1, green: 0.6666666667, blue: 0.01960784314, alpha: 1))
	static let FlashGreen = ColorGradient(from: .CommonGreen, to: #colorLiteral(red: 0.5176470588, green: 0.9215686275, blue: 0, alpha: 1))

	var colors: [UIColor] {
		[from, to]
	}
}

// MARK: - Update

public extension GradientView {
	func updateColors(_ gradient: ColorGradient) {
		self.updateColors(colors: [gradient.from, gradient.to])
	}
}
