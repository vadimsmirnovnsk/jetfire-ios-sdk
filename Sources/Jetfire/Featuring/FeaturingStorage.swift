import VNEssential
import UIKit
import UIColorHexSwift
import VNBase

/// Объект получает и хранит сториз и кампании для пользователя из нашего бэкенда
/// Здесь лежат вообще все сториз, которые мы получили с бэка
/// Дальше их нужно прогонять через availableStories, шедулить и закидывать в карусель
final class FeaturingStorage  {

	/// Чтобы не было циклической связи через FeaturingManager сетаю его в ините
	unowned var service: IStoriesService!

	/// Вообще все сториз, которые пришли с бэка
	private(set) var stories: [BaseStory] = []

	/// Мок для правил, которые должны приходить с бэка
	let rules: FeaturingRules = .demo

	var campaigns: [JetFireCampaign] { self.response?.campaigns ?? [] }
	var sql: JetFireFeaturesSql? { self.response?.sql }

	private(set) var response: JetFireListCampaignsResponse?

	private let api: IFeaturingAPI
	private let processTargetService: ProcessTargetService
	private let router: BaseRouter
	private let analytics: IStoriesAnalytics

	init(
		api: IFeaturingAPI,
		processTargetService: ProcessTargetService,
		router: BaseRouter,
		analytics: IStoriesAnalytics
	) {
		self.api = api
		self.processTargetService = processTargetService
		self.router = router
		self.analytics = analytics
	}

	func refetchFeaturingData(completion: @escaping (JetFireListCampaignsResponse?) -> Void) {
		self.api.fetchCampaigns { [weak self] res in
			guard let self = self else { return }
			switch res {
				case .failure:
					completion(nil)
				case .success(let response):
					self.response = response
					self.stories = response.campaigns.compactMap { self.createStory(for: $0) }
					completion(response)
			}
		}
	}

	func stories(for campaigns: [JetFireCampaign]) -> [BaseStory] {
		let ids = campaigns.map { $0.id }
		return self.stories.filter { ids.contains($0.content.story.campaignId) }
	}

	private func createStory(for campaign: JetFireCampaign) -> BaseStory? {
		guard let campaignStory = campaign.stories.first else { return nil }

		let infoStory = InfoStoryModel(
			id: campaignStory.id.string,
			campaignId: campaign.id,
			type: .firebaseInfo,
			title: campaignStory.cover.title,
			duration: 15,
			priority: Int(campaignStory.priority),
			image: campaignStory.cover.image.url,
			bgColorString: nil,
			afterReadTime: campaignStory.settings.afterReadExpire.timeInterval,
			isTest: nil,
			alwaysRewind: campaignStory.settings.alwaysRewind
		)
		let infoSnaps = campaignStory.frames.enumerated().map { index, fr in
			return InfoSnap(
				id: fr.id.string,
				storyId: campaignStory.id.string,
				campaignId: campaign.id,
				index: index,
				type: .info,
				title: fr.title,
				subtitle: fr.subtitle,
				message: fr.message,
				bgColorString: fr.background.color,
				bgImageString: fr.image.url,
				textColorString: fr.font.color,
				button: fr.storyButton()
			)
		}
		let storyContent = StoryContent(story: infoStory, snaps: infoSnaps)
		let cellVM = StoryInfoCellVM(infoStory: infoStory)
		let snapVMs = infoSnaps.map { InfoSnapVM(snap: $0, processTargetService: self.processTargetService, router: self.router, analytics: self.analytics) }
		let baseStory = BaseStory(service: self.service, analytics: self.analytics, content: storyContent, previewVM: cellVM, snaps: snapVMs)
		return baseStory
	}

}
