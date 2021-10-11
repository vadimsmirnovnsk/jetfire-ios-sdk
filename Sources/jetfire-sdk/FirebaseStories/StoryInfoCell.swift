import VNBase
import UIKit
import SDWebImage

final class StoryInfoCell: StoryCollectionBaseCell<StoryInfoCellVM> {

	private let image = UIImageView()
	private let alphaImage = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.image.sd_imageTransition = .fade
		self.image.contentMode = .scaleAspectFill
		self.content.addSubview(self.image) { make in
			make.edges.equalToSuperview()
		}

		self.alphaImage.alpha = 0.8
		self.alphaImage.contentMode = .scaleAspectFill
		self.alphaImage.sd_imageTransition = .fade
		self.content.addSubview(self.alphaImage) { make in
			make.edges.equalToSuperview()
		}
	}

	override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.content.backgroundColor = vm.bgColor
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

//	convenience init(userStory: IUserStoryModel) {
//		self.init(bgColor: .clear, imageURL: userStory.imageURL)
//	}

}

