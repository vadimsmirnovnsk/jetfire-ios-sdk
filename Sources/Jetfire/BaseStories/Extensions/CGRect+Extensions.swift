import UIKit

public extension CGRect {

	init(center: CGPoint, size: CGSize) {
		let origin = CGPoint(
			x: center.x - size.width / 2.0,
			y: center.y - size.height / 2.0
		)
		self.init(origin: origin, size: size)
	}

	var bounds: CGRect {
		return CGRect(origin: .zero, size: self.size)
	}

	var center: CGPoint {
		return CGPoint(x: self.midX, y: self.midY)
	}

	// Используется в частности после вызова метода boundingRect.
	//
	// This method returns fractional sizes (in the size component of the returned CGRect);
	// to use a returned size to size views, you must raise its value to the nearest higher integer
	// using the ceil function.
	//
	// https://developer.apple.com/documentation/foundation/nsstring/1524729-boundingrectwithsize
	func ceilBox() -> CGRect {
		return CGRect(
			x: self.origin.x,
			y: self.origin.y,
			width: ceil(self.width),
			height: ceil(self.height)
		)
	}

	func inset(by offset: CGFloat) -> CGRect {
		let insets = UIEdgeInsets(
			top: offset,
			left: offset,
			bottom: offset,
			right: offset
		)

		let rect = self.inset(by: insets)
		return rect
	}

}
