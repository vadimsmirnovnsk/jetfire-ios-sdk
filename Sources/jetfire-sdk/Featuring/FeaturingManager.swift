import VNEssential
import Foundation

/// Здесь логика выбора фичеринга по указанным в data.rules правилам
struct FeaturingCampaignAndStory {
	let campaign: FeaturingCampaign
	let story: BaseStory
}

final class FeaturingManager {

	var onFeaturingUpdated: Event<Void> { self.storage.onUpdateFeaturingData }

	private let storage: FeaturingStorage
	private let ud: IFUserDefaults

	init(ud: IFUserDefaults, storage: FeaturingStorage) {
		self.ud = ud
		self.storage = storage
	}

	func refetchData(competion: @escaping BoolBlock) {
		self.storage.refetchData(competion: competion)
	}

	func campaignForApplicationStart() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowApplicationStartFeaturing() else { return nil }
		return self.campaign(for: [.applicationStart])
	}

	func campaignForPush() -> FeaturingCampaignAndStory? {
		guard self.canAlreadyShowPushFeaturing() else { return nil }
		return self.campaign(for: [.push])
	}

	func trackShow(campaign: FeaturingCampaign, featuringType: FeaturingCampaign.FeaturingType) {
		self.ud.showCampaign[campaign.id] = Date()
		self.track(featuringType: featuringType)
	}

	func trackStartUsing(feature: String) {
	}

	func trackFinishUsing(feature: String) {
		self.ud.finishedFeatures.append(feature)
	}

	/// Отвратительный метод, переписать
	func retreiveCampaign(with identifier: String, completion: @escaping (FeaturingCampaignAndStory?) -> Void) {
		if let data = self.storage.data, let campaign = data.campaign(for: identifier) {
			if let story = self.storage.story(for: campaign.storyId) {
				completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
				return
			} else {
				/// Загрузилась дата, но не загрузились сториз, пробуем
				self.storage.refetchData { [weak self] _ in
					if let story = self?.storage.story(for: identifier) {
						completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
						return
					} else {
						completion(nil)
						return
					}
				}
			}
		} else {
			self.storage.refetchData { [weak self] _ in
				if let data = self?.storage.data, let campaign = data.campaign(for: identifier), let story = self?.storage.story(for: campaign.storyId) {
					completion(FeaturingCampaignAndStory(campaign: campaign, story: story))
					return
				} else {
					completion(nil)
					return
				}
			}
		}
	}

	private func track(featuringType: FeaturingCampaign.FeaturingType) {
		switch featuringType {
			case .applicationStart: self.ud.lastApplicationStartShowDate = Date()
			case .push: self.ud.lastPushShowDate = Date()
			case .toaster:  self.ud.lastToasterShowDate = Date()
		}
	}

	private func campaign(for types: [FeaturingCampaign.FeaturingType]) -> FeaturingCampaignAndStory? {
		guard let data = self.storage.data else {
			assertionFailure("Should not be nil. Call after fetching the data")
			return nil
		}
		guard data.rules.isFeaturingEnabled else { return nil }

		let activeAppStartCampaign = data.activeCampaigns
			.filter { self.canAlreadyShow(campaign: $0) }
			.filter { !self.ud.finishedFeatures.contains($0.feature) }
			.sorted { $0.priority > $1.priority }
			.first(where: { !Set($0.featuringTypes).intersection(Set(types)).isEmpty })

		let commonAppStartCampaign = data.commonCampaigns
			.filter { self.canAlreadyShow(campaign: $0) }
			.filter { !self.ud.finishedFeatures.contains($0.feature) }
			.sorted { $0.priority > $1.priority }
			.first(where: { !Set($0.featuringTypes).intersection(Set(types)).isEmpty })

		guard let campaign = activeAppStartCampaign ?? commonAppStartCampaign else { return nil }
		guard let story = self.storage.story(for: campaign.storyId) else { return nil }

		return FeaturingCampaignAndStory(campaign: campaign, story: story)
	}

	/// Можем ли показывать фичеринг в лицо повторно
	private func canAlreadyShowApplicationStartFeaturing() -> Bool {
		guard let data = self.storage.data else {
			assertionFailure("Should not be nil. Call after fetching the data")
			return false
		}
		guard let date = self.ud.lastApplicationStartShowDate else { return true }
		return Date().timeIntervalSince(date) > data.rules.retryApplicationStartShowTimeout
	}

	/// Можем ли показывать фичеринг пушом повторно
	private func canAlreadyShowPushFeaturing() -> Bool {
		guard let data = self.storage.data else {
			assertionFailure("Should not be nil. Call after fetching the data")
			return false
		}
		guard let date = self.ud.lastPushShowDate else { return true }
		return Date().timeIntervalSince(date) > data.rules.retryPushShowTimeout
	}

	/// Можем ли показать фичеринг конкретной фичи повторно
	private func canAlreadyShow(campaign: FeaturingCampaign) -> Bool {
		guard let data = self.storage.data else {
			assertionFailure("Should not be nil. Call after fetching the data")
			return false
		}
		guard let date = self.ud.showCampaign[campaign.id] else { return true }
		return Date().timeIntervalSince(date) > data.rules.retryFeatureShowTimeout
	}

}
