import UIKit

// Базовый класс кругляша, управляет прочтением сториз, открывает сториз по тапу
open class StoryCollectionBaseCell<TViewModel: StoryCollectionBaseCellVM>: BaseCollectionViewCell<TViewModel> {

	public override class func size(with viewModel: TViewModel, size: CGSize) -> CGSize { Jetfire.standard.cover.size }

	// Вьюха для контента кругляша, при тапе хайлайтится
	public let fgContent = UIView()
	// Вьюха для контента кругляша, при тапе не хайлайтится
	public let bgContent = UIView()

	open override var isHighlighted: Bool {
		didSet {
			let alpha: CGFloat = self.isHighlighted ? 0.7 : 1
			self.fgContent.alpha = alpha
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.contentView.addSubview(self.bgContent) { make in
			make.edges.equalToSuperview()
		}

		self.contentView.addSubview(self.fgContent) { make in
			make.edges.equalToSuperview()
		}
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
