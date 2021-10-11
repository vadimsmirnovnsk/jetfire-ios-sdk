import VNBase
import UIKit

open class StoryCollectionBaseCell<TViewModel: StoryCollectionBaseCellVM>: BaseCollectionViewCell<TViewModel> {

	public override class func size(with viewModel: TViewModel, size: CGSize) -> CGSize {
		return CGSize(width: .kStoryWidth, height: 100)
	}

	public var contentSize: CGFloat { 60 }

	open var readSubstrate: UIView = UIImageView(image:
		UIImage.circle(diameter: 68, color: .lightGray) // >>> 123
			.withOverdraw(image: UIImage.circle(diameter: 67, color: .white))
	)

	open var substrate: UIView = StorySubstrate(diameter: 68)

	let content = UIView()
	let title = UILabel()

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

		self.title.apply(StoriesConfig.standard.storyCircleTextStyle, text: vm.title, textAlignment: .center)
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
