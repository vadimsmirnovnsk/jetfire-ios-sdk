import VNEssential

/// Объект получает сториз из файербейз и кампании для пользователя
final class FeaturingStorage {

	let onUpdateFeaturingData = Event<Void>()
	private(set) var data: FeaturingData? {
		didSet {
			self.onUpdateFeaturingData.raise(())
		}
	}

	private let storiesService: StoriesService
	private let api: IFeaturingAPI
	private let userId: String

	init(storiesService: StoriesService, api: IFeaturingAPI, userId: String) {
		self.storiesService = storiesService
		self.api = api
		self.userId = userId
	}

	func refetchData(competion: @escaping BoolBlock) {
		self.storiesService.refetchStories { [weak self] in
			self?.refetchFeaturingData(competion: competion)
		}
	}

	func story(for storyId: String) -> BaseStory? {
		return self.storiesService.allStories.first(where: { $0.content.story.id == storyId })
	}

	private func refetchFeaturingData(competion: @escaping BoolBlock) {
		self.api.featchFeaturingRules(for: self.userId) { [weak self] data in
			self?.data = data
			competion(true)
		}
	}

}
