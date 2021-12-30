import VNBase
import VNEssential
import VNHandlers
import UIKit

/// Сервис, управляющий показом кругляшей, их загрузкой и сортировкой. 
final public class StoriesService {

	#if DEBUG
	private let showAll = true
	#else
	private let showAll = false
	#endif

	let onChangeStories = Event<Void>()
	/// Все истории в основной ленте — сверху экрана, данные для кругляшей
	private (set) var stories: [BaseStory] = []

	private let router: BaseRouter
	private let storage: IStoriesStorage
	private let ud: IUserDefaults

	private(set) var storageUpdated: Bool = false
	private var isReadyForReconstruct: Bool { self.storageUpdated }

	init(router: BaseRouter, storage: IStoriesStorage, ud: IUserDefaults) {
		self.router = router
		self.storage = storage
		self.ud = ud

		self.storage.service = self

		self.storage.onUpdateData.add(self) { [weak self] updated in
			if updated {
				DispatchQueue.main.async {
					self?.storageUpdated = true
					self?.reconstructStories()
				}
			}
		}
	}

	public func refetchStories(completion: @escaping BoolBlock) {
		self.storageUpdated = false
		self.storage.refetchStories(completion: completion)
	}

	private func reconstructStories() {
		guard self.isReadyForReconstruct else { return }
		var stories: [BaseStory] = []

		/// Получаем истории из сторейджа
		let approvedStories = self.storage.stories
			.filter { !($0.content.story.isTest ?? false) || self.showAll }
		stories.append(contentsOf: approvedStories)

		self.resort(newStories: stories)
	}

}

extension StoriesService: IStoryService {

	static let kSecondsInDay: TimeInterval = 60 * 60 * 24

	public func isRead(story: IStory) -> Bool {
		return self.ud.readStories[story.readId] != nil
	}

	public func markRead(story: IStory) {
		if self.isRead(story: story) { return }

		self.ud.readStories[story.readId] = Date()
		self.resortStories()
	}

	func shouldShowRead(story: IStory) -> Bool {
		guard let date = self.ud.readStories[story.readId] else { return true }
		return abs(Date().timeIntervalSince(date)) < story.lifetime * StoriesService.kSecondsInDay
	}

	public func show(story: BaseStory, in stories: [BaseStory]) {
		let vc = self.storiesVC(story: story, in: stories)
		vc.modalPresentationStyle = .fullScreen
		self.router.present(vc)
	}

	public func show(story: BaseStory) {
		guard self.stories.contains(story) else { return }
		self.show(story: story, in: self.stories.filter { !$0.snaps.isEmpty })
	}

	public func resortStories() {
		self.resort(newStories: self.stories)
	}

	private func resort(newStories: [BaseStory]) {
		let unread = newStories.filter { !$0.isRead }
			.sorted { $0.content.story.priority > $1.content.story.priority }
		let read = newStories.filter { $0.isRead }
			.filter { self.shouldShowRead(story: $0.content.story) }
			.sorted { $0.content.story.priority > $1.content.story.priority }
		let sortedStories = unread + read
		if self.stories != sortedStories {
			self.stories = sortedStories
			self.onChangeStories.raise(())
		}
	}

	private func storiesVC(story: BaseStory, in stories: [BaseStory]) -> UIViewController {
		let vm = StoryBrowserVM(storiesService: self, stories: stories, since: story)
		let vc = StoryBrowserVC(viewModel: vm)
		return vc
	}

}
