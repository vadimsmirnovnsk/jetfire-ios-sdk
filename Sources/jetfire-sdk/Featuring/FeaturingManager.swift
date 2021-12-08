import VNEssential
import Foundation

/// Здесь логика выбора фичеринга по указанным в data.rules правилам
struct FeaturingCampaignAndStory {
	let campaign: JetFireCampaign
	let story: BaseStory
}

final class FeaturingManager {

	var onFeaturingUpdated: Event<Void> { self.storage.onUpdateFeaturingData }

	private let storage: FeaturingStorage
	private let ud: IFUserDefaults
	private let db: DBAnalytics

	private var availableCampaigns: [JetFireCampaign] = []
	private var triggeredCampaigns: [JetFireCampaign] = []

	init(ud: IFUserDefaults, storage: FeaturingStorage, db: DBAnalytics) {
		self.ud = ud
		self.storage = storage
		self.db = db
	}

	func refetchData(completion: @escaping BoolBlock) {
		self.storage.refetchFeaturingData(completion: completion)
	}

	/// Дёргаем после рефетча, чтобы приготовить все availableCampaigns
	func prepareAvailableCampaigns() {
		if let availableSql = self.storage.sql?.available {
			let availableCampaignIds = self.db.execute(sql: availableSql)
			self.availableCampaigns = self.storage.campaigns.filter { availableCampaignIds.contains($0.id) }
		}
	}

	/// Дёргаем после триггера, чтобы показать нужный triggerCampaign
	func prepareTriggeredCampaigns() {
		if let triggerSql = self.storage.sql?.trigger {
			let triggeredCampaignIds = self.db.execute(sql: triggerSql)
			self.triggeredCampaigns = self.storage.campaigns.filter { triggeredCampaignIds.contains($0.id) }
		}
	}

	func campaignForApplicationStart() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowApplicationStartFeaturing() else { return nil }
		return self.campaign(for: .applicationStart)
	}

	func campaignForToaster() -> FeaturingCampaignAndStory? {
		#warning("123 Добавить чек на правило показа повторного тостера")
		guard let campaign = self.campaign(for: .toaster) else { return nil }
		guard self.canAlreadyShow(campaign: campaign.campaign) else { return nil }
		return campaign
	}

	func campaignForPush() -> FeaturingCampaignAndStory? {
//		guard self.canAlreadyShowPushFeaturing() else { return nil }
//		return self.campaign(for: [.push])
		return nil
	}

	func trackShow(campaign: JetFireCampaign, featuringType: FeaturingCampaign.FeaturingType) {
		self.ud.showCampaign[campaign.id.string] = Date()
		self.track(featuringType: featuringType)
	}

//	func trackStartUsing(feature: String) {
//	}

//	func trackFinishUsing(feature: String) {
//		self.ud.finishedFeatures.append(feature)
//	}

	private func track(featuringType: FeaturingCampaign.FeaturingType) {
		switch featuringType {
			case .applicationStart: self.ud.lastApplicationStartShowDate = Date()
			case .push: self.ud.lastPushShowDate = Date()
			case .toaster:  self.ud.lastToasterShowDate = Date()
			case .deeplink: break
		}
	}

	private func campaign(for type: FeaturingCampaign.FeaturingType) -> FeaturingCampaignAndStory? {
		guard self.storage.rules.isFeaturingEnabled else { return nil }

		switch type {
			case .applicationStart:
				guard let campaign = self.availableCampaigns.first(where: { !$0.hasPush && !$0.hasToaster } ) else { return nil }
				guard let story = self.storage.story(for: campaign) else { return nil }
				return FeaturingCampaignAndStory(campaign: campaign, story: story)

			case .deeplink: return nil
			case .push: return nil
			case .toaster:
				guard let campaign = self.triggeredCampaigns.first(where: { $0.hasToaster } ) else { return nil }
				guard let story = self.storage.story(for: campaign) else { return nil }
				return FeaturingCampaignAndStory(campaign: campaign, story: story)
		}


//		let activeAppStartCampaign = data.activeCampaigns
//			.filter { self.canAlreadyShow(campaign: $0) }
//			.filter { !self.ud.finishedFeatures.contains($0.feature) }
//			.sorted { $0.priority > $1.priority }
//			.first(where: { !Set($0.featuringTypes).intersection(Set(types)).isEmpty })

//		let commonAppStartCampaign = data.commonCampaigns
//			.filter { self.canAlreadyShow(campaign: $0) }
//			.filter { !self.ud.finishedFeatures.contains($0.feature) }
//			.sorted { $0.priority > $1.priority }
//			.first(where: { !Set($0.featuringTypes).intersection(Set(types)).isEmpty })

//		guard let campaign = activeAppStartCampaign ?? commonAppStartCampaign else { return nil }
//		guard let story = self.storage.story(for: campaign.storyId) else { return nil }
	}

	/// Можем ли показывать фичеринг в лицо повторно
	private func canAlreadyShowApplicationStartFeaturing() -> Bool {
		guard let date = self.ud.lastApplicationStartShowDate else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryApplicationStartShowTimeout
	}

	/// Можем ли показывать фичеринг пушом повторно
//	private func canAlreadyShowPushFeaturing() -> Bool {
//		guard let data = self.storage.data else {
//			assertionFailure("Should not be nil. Call after fetching the data")
//			return false
//		}
//		guard let date = self.ud.lastPushShowDate else { return true }
//		return Date().timeIntervalSince(date) > data.rules.retryPushShowTimeout
//	}

	/// Можем ли показать фичеринг конкретной фичи повторно
	private func canAlreadyShow(campaign: JetFireCampaign) -> Bool {
		guard let date = self.ud.showCampaign[campaign.id.string] else { return true }
		return Date().timeIntervalSince(date) > self.storage.rules.retryFeatureShowTimeout
	}

	/// Отвратительный метод, переписать. Он нужен для открытия кампании с пуша
	func retreiveCampaign(with identifier: String, completion: @escaping (FeaturingCampaignAndStory?) -> Void) {
//		if let data = self.storage.data, let campaign = data.campaign(for: identifier) {
//			if let story = self.storage.story(for: campaign.storyId) {
//				completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
//				return
//			} else {
//				/// Загрузилась дата, но не загрузились сториз, пробуем
//				self.storage.refetchData { [weak self] _ in
//					if let story = self?.storage.story(for: identifier) {
//						completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
//						return
//					} else {
//						completion(nil)
//						return
//					}
//				}
//			}
//		} else {
//			self.storage.refetchData { [weak self] _ in
//				if let data = self?.storage.data, let campaign = data.campaign(for: identifier), let story = self?.storage.story(for: campaign.storyId) {
//					completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
//					return
//				} else {
//					completion(nil)
//					return
//				}
//			}
//		}
	}

}
