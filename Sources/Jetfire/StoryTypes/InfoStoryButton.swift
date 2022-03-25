import VNEssential
import VNBase
import UIKit

final class InfoStoryButton: BlockButton {

	var onTouch: VoidBlock? = nil

	let title = UILabel()
	let titleAndImage = ImageAndLabelView(textInsets: UIEdgeInsets(top: 3, left: 6, bottom: 0, right: 0))
	let bgView: UIView

	private let style: SnapButtonStyle
	private let shadow = UIView()

	override var isHighlighted: Bool {
		didSet {
			self.updateSelection(selected: self.isSelected, highlighted: self.isHighlighted)
		}
	}

	override var isSelected: Bool {
		didSet {
			self.updateSelection(selected: self.isSelected, highlighted: self.isHighlighted)
		}
	}

	init(
		block: ButtonBlock? = nil,
		fadeOnHighlighted: Bool = false,
		height: CGFloat = UIView.noIntrinsicMetric,
		style: SnapButtonStyle
	) {
		self.style = style
		self.bgView = UIView.colored(style.bgColor)


		super.init(block: block)

		self.title.isUserInteractionEnabled = false
		self.bgView.isUserInteractionEnabled = false

		if self.style.addShadow {
			self.shadow.addShadow(color: UIColor.black,
								  offset: CGSize(width: 0.0, height: 5.0),
								  radius: 30.0, opacity: 0.3)
		}

		self.shadow.isUserInteractionEnabled = false
		self.addSubview(self.shadow) { make in
			make.edges.equalToSuperview()
		}

		let content = UIView()
		content.isUserInteractionEnabled = false
		content.setCornerRadius(self.style.cornerRadius)
		self.shadow.addSubview(content) { make in
			make.edges.equalToSuperview()
			make.height.equalTo(self.style.height)
			make.width.greaterThanOrEqualTo(self.style.preferredWidth).dgs_priority749()
		}

		content.addSubview(self.bgView) { make in make.edges.equalToSuperview() }
		content.addSubview(self.title) { make in
			make.edges.equalToSuperview().inset(self.style.titleInsets)
		}

		content.addSubview(self.titleAndImage) { make in
			make.center.equalToSuperview()
		}

		self.addTarget(self, action: #selector(self.didTouch), for: .touchDown)
	}

	func updateSelection(selected: Bool, highlighted: Bool) {
		let highlighted = selected || highlighted

		let alpha: CGFloat = highlighted ? 0.6 : 1
		self.title.alpha = alpha
		self.shadow.alpha = alpha
		self.bgView.alpha = alpha
	}

	@objc private func didTouch() {
		self.onTouch?()
	}

}
