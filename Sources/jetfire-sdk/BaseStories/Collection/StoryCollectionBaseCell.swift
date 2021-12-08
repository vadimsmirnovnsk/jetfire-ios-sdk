import VNBase
import UIKit

// Базовый класс кругляша
open class StoryCollectionBaseCell<TViewModel: StoryCollectionBaseCellVM>: BaseCollectionViewCell<TViewModel> {

	public override class func size(with viewModel: TViewModel, size: CGSize) -> CGSize {
		return CGSize(
			width: Jetfire.standard.storiesConfig.storyCircleCellWidth,
			height: Jetfire.standard.storiesConfig.storyCircleCellHeight
		)
	}

	public var contentSize: CGFloat { Jetfire.standard.storiesConfig.storyCircleImageDiameter }
	open var substrate: UIView = StorySubstrate(diameter: Jetfire.standard.storiesConfig.storyCircleSubstrateDiameter)

	open var readSubstrate: UIView = UIImageView(image: UIImage.circle(diameter: Jetfire.standard.storiesConfig.storyCircleSubstrateDiameter, color: .lightGray)
			.withOverdraw(image: UIImage.circle(diameter: Jetfire.standard.storiesConfig.storyCircleSubstrateDiameter - Jetfire.standard.storiesConfig.storyCircleSubstrateWidth, color: .white))
	)

	public let content = UIView()
	public let title = UILabel()

	open override var isHighlighted: Bool {
		didSet {
			let alpha: CGFloat = self.isHighlighted ? 0.6 : 1
			self.content.alpha = alpha
			self.title.alpha = alpha
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.contentView.addSubview(self.readSubstrate) { make in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(8)
		}

		self.substrate.isHidden = true
		self.contentView.addSubview(self.substrate) { make in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(8)
		}

		self.content.layer.cornerRadius = self.contentSize / 2
		self.content.layer.masksToBounds = true
		self.content.isUserInteractionEnabled = false
		self.contentView.addSubview(self.content) { make in
			make.center.equalTo(self.substrate)
			make.size.equalTo(self.contentSize)
		}

		self.contentView.addSubview(self.title) { make in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-4)
			make.width.equalToSuperview()
		}
	}

	public override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.title.apply(Jetfire.standard.storiesConfig.storyCircleTextStyle, text: vm.title, textAlignment: .center)
		self.substrate.isHidden = vm.isRead
	}

}

open class StoryCollectionBaseCellVM: BaseCellVM {

	weak var story: BaseStory? = nil {
		didSet {
			self.loadStoryContent()
		}
	}

	open var isRead: Bool = false {
		didSet {
			self.viewModelChanged()
		}
	}

	open var title: String = ""

	open override func handleSelection(animated: Bool) {
		super.handleSelection(animated: animated)

		guard let story = self.story else {
			assertionFailure("Must have a story")
			return
		}

		story.didTapInPreview()
	}

	private func loadStoryContent() {
		guard let story = self.story else { return }
		self.title = story.content.story.title
		self.isRead = story.isRead
	}

}
