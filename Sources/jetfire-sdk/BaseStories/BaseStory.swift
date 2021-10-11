import VNBase

// Это объект, связывающий вьюмодельки превью и браузера сториз
// В нём вьюмодельки, чтобы сториз могли быть с разными вьюмодельками
open class BaseStory: Equatable {

	let content: StoryContent

	private(set) var isRead: Bool = false {
		didSet {
			self.previewCellVM.isRead = self.isRead
		}
	}

	public let previewCellVM: StoryCollectionBaseCellVM
	var snaps: [BaseSnap] { self.snapVMs.map { BaseSnap(snapVM: $0) } }
	let snapVMs: [BaseSnapVM]

	unowned let service: IStoryService!

	init(service: IStoryService, content: StoryContent,
		 previewVM: StoryCollectionBaseCellVM, snaps: [BaseSnapVM])
	{
		self.service = service
		self.content = content
		self.previewCellVM = previewVM
		self.snapVMs = snaps
		self.isRead = service.isRead(story: content.story)

		self.previewCellVM.story = self
	}

	public func mark(read: Bool) {
		self.isRead = read

		if read {
			self.service.markRead(story: self.content.story)
		}
	}

	public func didTapInPreview() {
		guard !self.snaps.isEmpty else {
			assertionFailure("Should not be empty")
			return
		}

		if let service = self.service {
			service.show(story: self)
		}
	}

	public func willAppearSnap(with index: Int) {
		if index == 0 {
			self.snaps.forEach { $0.snapVM.isRead = false }
		}

		self.snaps.safeObject(at: index)?.snapVM.appear()
		self.snaps.safeObject(at: index - 1)?.snapVM.isRead = true

		Jetfire.analytics.trackStorySnapDidShow(storyId: self.content.story.id, index: index)

		if index == 0 {
			Jetfire.analytics.trackStoryDidStartShow(storyId: self.content.story.id)
		} else if index == self.snaps.count - 1 {
			Jetfire.analytics.trackStoryDidFinishShow(storyId: self.content.story.id)
		}
	}

	/// MARK: Equatable

	public static func == (lhs: BaseStory, rhs: BaseStory) -> Bool {
		return lhs.content.story.id == rhs.content.story.id
	}

}
