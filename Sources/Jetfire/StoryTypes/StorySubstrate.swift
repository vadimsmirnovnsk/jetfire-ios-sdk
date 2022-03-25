import UIKit

// Градиентная подложка непрочитанной сториз
final class StorySubstrate: UIView {

	private let gradient = CAGradientLayer()

	convenience init(substrate: CoverSubstrate) {
		self.init(
			size: substrate.size,
			cornerRadius: substrate.cornerRadius,
			width: substrate.width,
			startColor: substrate.startColor,
			endColor: substrate.endColor,
			startPoint: substrate.startPoint,
			endPoint: substrate.endPoint
		)
	}

	init(size: CGSize, cornerRadius: CGFloat, width: CGFloat, startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
		super.init(frame: .zero)

		let rectCenter = CGPoint(x: size.width / 2, y: size.height / 2)
		let path = UIBezierPath(roundedRect: CGRect(center: rectCenter, size: size), cornerRadius: cornerRadius)
		let innerSize: CGSize = width >= 0
			? CGSize(width: size.width - (width * 2), height: size.height - (width * 2))
			: .zero

		let sizeRadiusRatio = min(size.width, size.height) == 0 || cornerRadius == 0
			? 0
			: cornerRadius / min(size.width, size.height)
		let innerRadius: CGFloat = min(innerSize.width, innerSize.height) == 0 || cornerRadius == 0
			? 0
			: min(innerSize.width, innerSize.height) * sizeRadiusRatio
		let inner = UIBezierPath(roundedRect: CGRect(center: rectCenter, size: innerSize), cornerRadius: innerRadius)

		path.append(inner.reversing())
		path.usesEvenOddFillRule = true

		let shape = CAShapeLayer()
		shape.path = path.cgPath
		shape.fillColor = UIColor.black.cgColor

		self.gradient.startPoint = CGPoint(x: 0, y: 0)
		self.gradient.endPoint = CGPoint(x: 1, y: 1)
		self.gradient.colors = [ startColor.cgColor, endColor.cgColor ]

		self.gradient.mask = shape

		self.layer.addSublayer(self.gradient)
		self.layer.masksToBounds = true

		self.isUserInteractionEnabled = false
		self.snp.makeConstraints { make in
			make.size.equalTo(size)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.gradient.frame = self.bounds
	}

}
