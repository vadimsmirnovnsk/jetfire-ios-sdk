import UIKit

final class StorySubstrate: UIView {

	private let gradient = CAGradientLayer()

	init(diameter: CGFloat) {
		super.init(frame: .zero)

		let ovalCenter = CGPoint(x: diameter / 2, y: diameter / 2)
		let path = UIBezierPath(ovalIn: CGRect(center: ovalCenter, size: CGSize(diameter)))
		let inner = UIBezierPath(ovalIn: CGRect(center: ovalCenter, size: CGSize(diameter - 4)))
		path.append(inner.reversing())
		path.usesEvenOddFillRule = true

		let shape = CAShapeLayer()
		shape.path = path.cgPath
		shape.fillColor = UIColor.black.cgColor

		self.gradient.startPoint = CGPoint(x: 0, y: 0)
		self.gradient.endPoint = CGPoint(x: 1, y: 1)
		self.gradient.colors = [
			StoriesConfig.standard.storyCircleRingRightGradientColor.cgColor,
			StoriesConfig.standard.storyCircleRingLeftGradientColor.cgColor
		]

		self.gradient.mask = shape

		self.layer.addSublayer(self.gradient)

		self.isUserInteractionEnabled = false
		self.snp.makeConstraints { make in
			make.size.equalTo(diameter)
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
