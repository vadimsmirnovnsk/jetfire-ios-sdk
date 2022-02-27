import VNEssential
import Foundation

/// Здесь логика выбора фичеринга по указанным в data.rules правилам
struct FeaturingCampaignAndStory {
	let campaign: JetFireCampaign
	let story: BaseStory
}

final class FeaturingManager: IStoriesDataSource {

	/// Здесь только сториз, которые доступны пользователю
	private(set) var stories: [BaseStory] = []
	unowned var service: IStoriesService!
	var onChanged = Event<Void>()

	var onFeaturingUpdated: Event<Void> { self.onChanged }

	private let storage: FeaturingStorage
	private let ud: IUserSettings
	private let db: IDatabaseService

	private var availableCampaigns: [JetFireCampaign] = []
	private var triggeredCampaigns: [JetFireCampaign] = []

	init(ud: IUserSettings, storage: FeaturingStorage, db: IDatabaseService) {
		self.ud = ud
		self.storage = storage
		self.db = db
	}

    func fetchStories(completion: @escaping (Result<[BaseStory], Error>) -> Void) {
        completion(.success(self.stories))
    }

	func refetchData(completion: @escaping BoolBlock) {
		self.storage.refetchFeaturingData { res in
			completion(res != nil)
		}
	}

	/// Дёргаем после каждого события чтобы приготовить все availableCampaigns
	func prepareAvailableCampaigns() {
		if let availableSql = self.storage.sql?.stories {
			let availableCampaignIds = self.db.execute(sql: availableSql)
			self.availableCampaigns = self.storage.campaigns.filter { availableCampaignIds.contains($0.id) }
			let newStories = self.storage.stories(for: self.availableCampaigns)
			if self.stories != newStories {
				self.stories = newStories
				self.onChanged.raise(())
			}
		}
	}

	/// Дёргаем после триггера, чтобы показать нужный triggerCampaign
	func prepareTriggeredCampaigns() {
//		if let triggerSql = self.storage.sql?.trigger {
//			let triggeredCampaignIds = self.db.execute(sql: triggerSql)
//			self.triggeredCampaigns = self.storage.campaigns
//				.filter { $0.hasPush || $0.hasToaster }
//				.filter { triggeredCampaignIds.contains($0.id) }
//		}
	}

	func campaignForApplicationStart() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowApplicationStartFeaturing() else { return nil }
		guard let campaign = self.campaign(for: .applicationStart) else { return nil }
		guard self.canAlreadyShow(campaign: campaign.campaign) else { return nil }
		return campaign
	}

	func campaignForToaster() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowToasterFeaturing() else { return nil }
		guard let campaign = self.campaign(for: .toaster) else { return nil }
		guard self.canAlreadyShow(campaign: campaign.campaign) else { return nil }
		return campaign
	}

	func campaignForPush() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowPushFeaturing() else { return nil }
		guard let campaign = self.campaign(for: .push) else { return nil }
		guard self.canAlreadyShow(campaign: campaign.campaign) else { return nil }
		return campaign
	}

	private func campaign(for type: FeaturingType) -> FeaturingCampaignAndStory? {
		guard self.storage.rules.isFeaturingEnabled else { return nil }

		switch type {
			case .applicationStart:
				#warning("Переделать на application start?")
				guard let campaign = self.availableCampaigns.first(where: { !$0.hasPush && !$0.hasToaster && $0.canSchedule } ) else { return nil }
				guard let story = self.storage.stories(for: [campaign]).first else { return nil }
				return FeaturingCampaignAndStory(campaign: campaign, story: story)

			case .push:
				guard let campaign = self.triggeredCampaigns.filter({ $0.hasPush && $0.canSchedule }).first  else { return nil }
				guard let story = self.storage.stories(for: [campaign]).first else { return nil }
				return FeaturingCampaignAndStory(campaign: campaign, story: story)

			case .toaster:
				guard let campaign = self.triggeredCampaigns.first(where: { $0.hasToaster } ) else { return nil }
				guard let story = self.storage.stories(for: [campaign]).first else { return nil }
				return FeaturingCampaignAndStory(campaign: campaign, story: story)

			case .deeplink: return nil
		}
	}

	/// Можем ли показывать фичеринг в лицо повторно
	private func canAlreadyShowApplicationStartFeaturing() -> Bool {
		guard let date = self.ud.lastApplicationStartShowDate else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryApplicationStartShowTimeout
	}

	/// Можем ли показывать тостер повторно
	private func canAlreadyShowToasterFeaturing() -> Bool {
		guard let date = self.ud.lastToasterShowDate else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryToasterShowTimeout
	}

	/// Можем ли показывать фичеринг пушом повторно
	private func canAlreadyShowPushFeaturing() -> Bool {
		guard let date = self.ud.lastPushShowDate else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryPushShowTimeout
	}

	/// Можем ли показать фичеринг конкретной фичи повторно
	private func canAlreadyShow(campaign: JetFireCampaign) -> Bool {
		guard let date = self.ud.showCampaign[campaign.id.string] else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryFeatureShowTimeout
	}

	/// Метод для открытия кампании с пуша
	func retreiveCampaign(with identifier: String, completion: @escaping (FeaturingCampaignAndStory?) -> Void) {
		if let campaign = (self.triggeredCampaigns + self.availableCampaigns).first(where: { $0.id.string == identifier }),
			let story = self.storage.stories(for: [campaign]).first
		{
			completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
			return
		}

		#warning("Загрузить с бэка кампанию")
		completion(nil)
	}

}
