import UIKit

class PassOverTouchesView: UIView {

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let resultView = super.hitTest(point, with: event)
		if resultView === self {
			return nil
		}
		return resultView
	}

}
