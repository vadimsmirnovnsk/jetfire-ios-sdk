import VNBase
import VNEssential
import VNHandlers
import UIKit

final public class StoriesService {

	#if DEBUG
	private let showAll = true
	#else
	private let showAll = false
	#endif

	let onChangeStories = Event<Void>()
	/// Все истории в основной ленте — сверху экрана, данные для кругляшей
	private (set) var avatarStories: [BaseStory] = []
	var allStories: [BaseStory] { self.storage.stories }

	private let api: IAPIService
	private let router: BaseRouter
	private let storage: StoriesStorage
	private let ud: IUserDefaults
	private let processTargetService: ProcessTargetService

	private var storageUpdated: Bool = false
	private var isReadyForReconstruct: Bool { self.storageUpdated }

	init(router: BaseRouter, api: IAPIService, storage: StoriesStorage, processTargetService: ProcessTargetService, ud: IUserDefaults) {
		self.router = router
		self.api = api
		self.storage = storage
		self.processTargetService = processTargetService
		self.ud = ud

		self.storage.service = self
	}

	public func refetchStories(completion: @escaping VoidBlock) {
		self.storageUpdated = false
		self.storage.fetchStories { [weak self] _ in
			DispatchQueue.main.async {
				self?.storageUpdated = true
				self?.reconstructStories()
				completion()
			}
		}
	}

	private func reconstructStories() {
		guard self.isReadyForReconstruct else { return }
		var stories: [BaseStory] = []

		/// С файербейза
		let approvedStories = self.storage.stories
			.filter { !($0.content.story.isTest ?? false) || self.showAll }
		stories.append(contentsOf: approvedStories)
		self.avatarStories = stories

		self.resortStories()
	}

}

extension StoriesService: IStoryService {

	static let kSecondsInDay: TimeInterval = 60 * 60 * 24

	public func isRead(story: IStory) -> Bool {
		return self.ud.readStories[story.id] != nil
	}

	public func markRead(story: IStory) {
		if self.isRead(story: story) { return }

		self.ud.readStories[story.id] = Date()
	}

	func shouldShowRead(story: IStory) -> Bool {
		guard let date = self.ud.readStories[story.id] else { return true }
		return abs(Date().timeIntervalSince(date)) < story.lifetime * StoriesService.kSecondsInDay
	}

	public func show(story: BaseStory, in stories: [BaseStory]) {
		let vc = self.storiesVC(story: story, in: stories)
		vc.modalPresentationStyle = .fullScreen
		self.router.present(vc)
	}

	public func show(story: BaseStory) {
		guard self.avatarStories.contains(story) else { return }
		self.show(story: story, in: self.avatarStories.filter { !$0.snaps.isEmpty })
	}

	public func resortStories() {
		let unread = self.avatarStories.filter { !$0.isRead }
			.sorted { $0.content.story.priority > $1.content.story.priority }
		let read = self.avatarStories.filter { $0.isRead }
			.filter { self.shouldShowRead(story: $0.content.story) }
			.sorted { $0.content.story.priority > $1.content.story.priority }
		self.avatarStories = unread + read
		self.onChangeStories.raise(())
	}

	private func storiesVC(story: BaseStory, in stories: [BaseStory]) -> UIViewController {
		let vm = StoryBrowserVM(storiesService: self, stories: stories, since: story)
		let vc = StoryBrowserVC(viewModel: vm)
		return vc
	}

}
