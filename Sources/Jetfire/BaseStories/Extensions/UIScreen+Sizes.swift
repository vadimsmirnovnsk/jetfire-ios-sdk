import UIKit

extension UIScreen {

	var isSmall: Bool {
		let minSize = min(self.bounds.width, self.bounds.height)
		return minSize <= 320
	}

}
