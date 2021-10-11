import UserNotifications

/// Класс — точка входа на фичеринг снаружи.
/// Он получает решения от фичеринг менеджера и показывает фичеринг + трекает события
final public class FeaturingService {

	private let manager: FeaturingManager
	private let storiesService: IStoryService
	private let pushService: FeaturingPushService

	internal init(manager: FeaturingManager, storiesService: IStoryService, pushService: FeaturingPushService) {
		self.manager = manager
		self.storiesService = storiesService
		self.pushService = pushService
	}

	/// На старте загружаем данные, по готовности показываем фичеринг и шедулим пуш активной кампании
	public func applicationStart() {
		self.manager.refetchData { [weak self] _ in
			self?.showApplicationStartFeaturing()
			self?.subscribeOnDataUpdates()
			self?.reschedulePushFeaturing()
		}

		Anl.track { $0.name(.firetest_application_start) }
	}

	public func applicationDidBecomeActive() {
		Anl.track { $0.name(.firetest_become_active) }
	}

	public func applicationWillResignActive() {
		Anl.track { $0.name(.firetest_resign_active) }

		self.pushService.scheduleActiveFeaturing { campaign in
			self.manager.trackShow(campaign: campaign, featuringType: .push)

			Anl.track { track in
				track.name(.firetest_featuring_trigger_show)
					.param(.firetest_featuring_id, value: campaign.id)
					.param(.firetest_trigger_type, value: String.kPush)
			}
		}
	}

	public func trackStart(feature: String) {
		self.manager.trackStartUsing(feature: feature)
		self.reschedulePushFeaturing()

		Anl.track { track in
			track.name(.firetest_feature_start)
				.param(.firetest_featuring_id, value: feature)
		}
	}

	public func trackFinish(feature: String) {
		self.manager.trackFinishUsing(feature: feature)
		self.reschedulePushFeaturing()

		Anl.track { track in
			track.name(.firetest_feature_finish)
				.param(.firetest_featuring_id, value: feature)
		}
	}

	public func updatePushStatus(granted: Bool) {
		self.pushService.update(granted: granted)
	}

	/// MARK: Private
	/// При обновлении статуса пуш-нотификаций дёргается метод и перенастраивает пуш-компанию на следующую непоказанную
	private func reschedulePushFeaturing() {
		guard self.pushService.isGranted else {
			self.pushService.removeAllFeaturings()
			return
		}

		self.pushService.resetPreparingFeaturing()
		guard let campaign = self.manager.campaignForPush() else { return }
		self.pushService.prepareFeaturing(campaign: campaign.campaign)
	}

	private func showApplicationStartFeaturing() {
		guard let campaign = self.manager.campaignForApplicationStart() else { return }
		self.show(campaign: campaign, featuringType: .applicationStart)
	}

	private func show(campaign: FeaturingCampaignAndStory, featuringType: FeaturingCampaign.FeaturingType) {
		self.manager.trackShow(campaign: campaign.campaign, featuringType: featuringType)
		Anl.track { track in
			track.name(.firetest_featuring_campaign_show)
				.param(.firetest_featuring_type, value: featuringType.rawValue)
				.param(.firetest_featuring_id, value: campaign.campaign.id)
		}
		self.storiesService.show(story: campaign.story, in: [campaign.story])
	}

	private func subscribeOnDataUpdates() {
		self.manager.onFeaturingUpdated.add(self) { [weak self] _ in
			self?.reschedulePushFeaturing()
		}

		self.pushService.onGrantedEvent.add(self) { [weak self] _ in
			self?.reschedulePushFeaturing()
		}
	}

}

extension FeaturingService {

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) {
		let campaignId = self.pushService.campaignId(from: response)
		self.manager.retreiveCampaign(with: campaignId) { [weak self] campaign in
			guard let campaign = campaign else { return }
			self?.show(campaign: campaign, featuringType: .push)
		}
	}

}
