import UIKit

extension CGSize {

	var aspect: CGFloat {
		guard self.width > 0, self.height > 0 else { return 1 }
		return self.height / self.width
	}

	init(_ square: CGFloat) {
		self.init(width: square, height: square)
	}

	func map(result: (_ width: CGFloat, _ height: CGFloat) -> (CGFloat, CGFloat)) -> CGSize {
		let newTuple = result(self.width, self.height)
		return CGSize(width: newTuple.0, height: newTuple.1)
	}

}
