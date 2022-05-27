import JetfireVNBase
import UIKit

extension GradientView {

	static func verticalReversedGray() -> GradientView {
		return self.vertical(from: UIColor.black.withAlphaComponent(0),
							 to: UIColor.black.withAlphaComponent(0.3))
	}

	static func verticalGray() -> GradientView {
		return self.vertical(from: UIColor.black.withAlphaComponent(0.3),
							 to: UIColor.black.withAlphaComponent(0))
	}

	static func vertical(from: UIColor, to: UIColor) -> GradientView {
		return GradientView(colors: [ from, to ], points: Points(start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1)))
	}

}
