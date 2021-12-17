import VNEssential
import UIKit
import UIColorHexSwift
import VNBase

/// Объект получает и хранит сториз и кампании для пользователя из нашего бэкенда
final class FeaturingStorage: IStoriesStorage {

	unowned var service: IStoryService!
	private(set) var stories: [BaseStory] = []

	var onUpdateData = Event<Bool>()

	let rules: FeaturingRules = .demo
	var campaigns: [JetFireCampaign] { self.response?.campaigns ?? [] }
	var sql: JetFireFeaturesSql? { self.response?.sql }

	private(set) var response: JetFireListCampaignsResponse? {
		didSet {
			self.onUpdateData.raise(true)
		}
	}

	private let api: IFeaturingAPI
	private let processTargetService: ProcessTargetService
	private let router: BaseRouter

	init(api: IFeaturingAPI, processTargetService: ProcessTargetService, router: BaseRouter) {
		self.api = api
		self.processTargetService = processTargetService
		self.router = router
	}

	/// IStoriesStorage
	func refetchStories(completion: @escaping BoolBlock) {
		self.refetchFeaturingData(completion: completion)
	}

	func refetchFeaturingData(completion: @escaping BoolBlock) {
		self.api.fetchCampaigns { [weak self] res in
			guard let self = self else { return }
			switch res {
				case .failure(let error):
					print("Fetched campaigns error: \(error)")
					self.onUpdateData.raise(false)
					completion(false)

				case .success(let response):
					print("Fetched campaigns data: \(response)")
					self.response = response
					self.stories = response.campaigns.compactMap { self.story(for: $0) }
					self.onUpdateData.raise(true)
					completion(true)
			}
		}
	}

	//	func refetchData(competion: @escaping BoolBlock) {
	//		self.storiesService.refetchStories { [weak self] in
	//			self?.refetchFeaturingData(competion: competion)
	//		}
	//	}

	func story(for campaign: JetFireCampaign) -> BaseStory? {
		guard let campaignStory = campaign.stories.first else { return nil }

		let infoStory = InfoStoryModel(
			id: campaign.id.string,
			type: .firebaseInfo,
			title: campaign.toaster.title,
			duration: 15,
			priority: 100,
			image: nil,
			bgColorString: nil,
			afterReadTime: nil,
			isTest: nil,
			alwaysRewind: nil
		)
		let infoSnaps = campaignStory.frames.map { fr in
			return InfoSnap(
				id: fr.id.string,
				type: .info,
				title: fr.title,
				subtitle: fr.subtitle,
				message: fr.message,
				bgColorString: fr.background.color,
				bgImageString: fr.image.url,
				textColorString: fr.font.color,
				button: nil
			)
		}
		let storyContent = StoryContent(story: infoStory, snaps: infoSnaps)
		let cellVM = StoryInfoCellVM(infoStory: infoStory)
		let snapVMs = infoSnaps.map { InfoSnapVM(snap: $0, processTargetService: self.processTargetService, router: self.router) }
		let baseStory = BaseStory(service: self.service, content: storyContent, previewVM: cellVM, snaps: snapVMs)
		return baseStory
	}

}
