import JetfireVNBase
import UIKit

final class ImageAndLabelView: UIView {

	public enum Style {
		case leftImage
		case rightImage
		case topImage
		case topLeftImage
	}

	let title = MultilineLabel()
	let image = UIImageView()

	init(image: UIImage? = nil, style: ImageAndLabelView.Style = .leftImage,
		 textInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
	{
		super.init(frame: .zero)

		self.image.image = image
		self.image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		self.image.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

		self.title.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		self.title.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

		switch style {
			case .leftImage:
				self.addSubview(self.image) { make in
					make.left.top.bottom.equalToSuperview()
				}
				self.addSubview(self.title) { make in
					make.left.equalTo(self.image.snp.right).offset(textInsets.left)
					make.centerY.equalToSuperview().offset(textInsets.top)
					make.right.equalToSuperview().offset(-textInsets.right)
				}

			case .rightImage:
				self.addSubview(self.image) { make in
					make.right.top.bottom.equalToSuperview()
				}
				self.addSubview(self.title) { make in
					make.left.equalToSuperview().offset(textInsets.left)
					make.centerY.equalToSuperview().offset(textInsets.top)
					make.right.equalTo(self.image.snp.left).offset(-textInsets.right)
				}

			case .topImage:
				self.addSubview(self.image) { make in
					make.top.centerX.equalToSuperview()
					make.width.lessThanOrEqualToSuperview().dgs_priority749()
				}

				self.addSubview(self.title) { make in
					make.top.equalTo(self.image.snp.bottom).offset(textInsets.top)
					make.width.lessThanOrEqualToSuperview().dgs_priority749()
					make.bottom.equalToSuperview()
				}

			case .topLeftImage:
				self.addSubview(self.image) { make in
					make.top.equalToSuperview()
					make.left.equalToSuperview().offset(textInsets.left)
					make.width.lessThanOrEqualToSuperview().dgs_priority749()
				}

				self.addSubview(self.title) { make in
					make.top.equalTo(self.image.snp.bottom).offset(textInsets.top)
					make.width.lessThanOrEqualToSuperview().dgs_priority749()
					make.bottom.equalToSuperview()
				}
		}

	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
