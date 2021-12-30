import VNBase
import UIKit
import SDWebImage

final class StoryInfoCell: StoryCollectionBaseCell<StoryInfoCellVM> {

	private let substrate: UIView = StorySubstrate(substrate: Jetfire.standard.cover.substrate)
	private let readSubstrate: UIView = StorySubstrate(substrate: Jetfire.standard.cover.readSubstrate)

	private let imageContainer = UIView()
	private let image = UIImageView()
	private let alphaImage = UIImageView()

	private let title = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.backgroundColor = Jetfire.standard.cover.bgColor
		self.contentView.backgroundColor = Jetfire.standard.cover.bgColor

		self.fgContent.addSubview(self.readSubstrate) { make in
			make.centerX.equalToSuperview().offset(Jetfire.standard.cover.readSubstrate.centerInset.x)
			make.centerY.equalToSuperview().offset(Jetfire.standard.cover.readSubstrate.centerInset.y)
		}

		self.substrate.isHidden = true
		self.fgContent.addSubview(self.substrate) { make in
			make.centerX.equalToSuperview().offset(Jetfire.standard.cover.substrate.centerInset.x)
			make.centerY.equalToSuperview().offset(Jetfire.standard.cover.substrate.centerInset.y)
		}

		self.imageContainer.setCornerRadius(Jetfire.standard.cover.image.cornerRadius)
		self.imageContainer.clipsToBounds = true
		self.imageContainer.isUserInteractionEnabled = false
		self.fgContent.addSubview(self.imageContainer) { make in
			make.size.equalTo(Jetfire.standard.cover.image.size)
			make.centerX.equalToSuperview().offset(Jetfire.standard.cover.image.centerInset.x)
			make.centerY.equalToSuperview().offset(Jetfire.standard.cover.image.centerInset.y)
		}

		self.image.sd_imageTransition = .fade
		self.image.contentMode = .scaleAspectFill
		self.imageContainer.addSubview(self.image) { make in
			make.edges.equalToSuperview()
		}

		self.alphaImage.alpha = Jetfire.standard.cover.image.readAlpha
		self.alphaImage.contentMode = .scaleAspectFill
		self.alphaImage.sd_imageTransition = .fade
		self.imageContainer.addSubview(self.alphaImage) { make in
			make.edges.equalToSuperview()
		}

		if let gradient = Jetfire.standard.cover.gradient {
			let g = GradientView(
				colors: [ gradient.startColor, gradient.endColor ],
				points: GradientView.Points(start: gradient.startPoint, end: gradient.endPoint)
			)

			self.fgContent.addSubview(g) { make in
				make.size.equalTo(gradient.size)
				make.centerX.equalToSuperview().offset(gradient.centerInset.x)
				make.centerY.equalToSuperview().offset(gradient.centerInset.y)
			}
		}

		self.fgContent.addSubview(self.title) { make in
			make.left.bottom.right.equalToSuperview().inset(Jetfire.standard.cover.title.bottomInset)
		}
	}

	override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.title.apply(
			Jetfire.standard.cover.title.textStyle,
			text: vm.title,
			textAlignment: Jetfire.standard.cover.title.textAlignment
		)
		self.substrate.isHidden = vm.isRead
		self.readSubstrate.isHidden = !vm.isRead

		self.bgContent.backgroundColor = vm.bgColor
		self.image.sd_setImage(with: vm.imageURL,
							   placeholderImage: nil,
							   options: [.transformAnimatedImage]) { _,_,_,_ in }
		self.alphaImage.sd_setImage(with: vm.alphaImageURL,
									placeholderImage: nil,
									options: [.transformAnimatedImage]) { _,_,_,_ in }
		self.alphaImage.isHidden = vm.alphaImageURL == nil
	}

}

final class StoryInfoCellVM: StoryCollectionBaseCellVM {

	let bgColor: UIColor
	let imageURL: URL?
	let alphaImageURL: URL?

	init(bgColor: UIColor, imageURL: URL?, alphaImageURL: URL? = nil) {
		self.bgColor = bgColor
		self.imageURL = imageURL
		self.alphaImageURL = alphaImageURL
	}

	convenience init(infoStory: InfoStoryModel) {
		self.init(bgColor: infoStory.bgColor, imageURL: infoStory.imageURL)
	}

}

