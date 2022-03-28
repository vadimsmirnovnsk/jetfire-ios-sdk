import VNBase
import UIKit

final class GhostRecognizer: UIGestureRecognizer {

	private let gestureBlock: BoolBlock

	init(gestureBlock: @escaping BoolBlock) {
		self.gestureBlock = gestureBlock

		super.init(target: nil, action: nil)

		self.state = .possible
		self.cancelsTouchesInView = false
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesBegan(touches, with: event)

		self.gestureBlock(true)
		self.state = .began
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesEnded(touches, with: event)

		self.gestureBlock(false)
		self.state = .ended
	}

	override func reset() {
		self.state = .possible
	}

}
