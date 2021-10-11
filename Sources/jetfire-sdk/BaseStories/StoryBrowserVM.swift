import VNBase

protocol IStoryBrowserDelegate: AnyObject {
	func skip(cellVM: StoryBrowserCellVM)

	// Return true if possible
	func rewind(cellVM: StoryBrowserCellVM) -> Bool
	func pause()
	func close()
}

final class StoryBrowserVM: BaseViewControllerVM {

	var sinceIndex: Int { return self.stories.indexes(of: self.since).first ?? 0 }
	private(set) var rows: [StoryBrowserCellVM] = []

	weak var browserDelegate: IStoryBrowserDelegate? = nil {
		didSet {
			self.throwDelegate()
		}
	}

	private let stories: [BaseStory]
	private let since: BaseStory
	private let storiesService: IStoryService

	init(storiesService: IStoryService, stories: [BaseStory], since: BaseStory) {
		self.stories = stories
		self.since = since
		self.storiesService = storiesService

		super.init()

		self.rows = stories.map { StoryBrowserCellVM(story: $0) }
		self.throwDelegate()
	}

	private func throwDelegate() {
		self.rows.forEach { $0.delegate = self.browserDelegate }
	}

	func pause() {
		self.rows.forEach { $0.goProgress(go: false) }
	}

	func didWatchStories() {
		self.storiesService.resortStories()
	}

}
