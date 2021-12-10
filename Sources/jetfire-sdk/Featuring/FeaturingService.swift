import UserNotifications
import UIKit

/// Класс — точка входа на фичеринг снаружи.
/// Он получает решения от фичеринг менеджера и показывает фичеринг + трекает события
final public class FeaturingService {

	private let manager: FeaturingManager
	private let storiesService: IStoryService
	private let pushService: FeaturingPushService
	private let dbAnalytics: DBAnalytics
	private let ud: IFUserDefaults
	private let router: FeaturingRouter

	init(
		manager: FeaturingManager,
		storiesService: IStoryService,
		pushService: FeaturingPushService,
		dbAnalytics: DBAnalytics,
		ud: IFUserDefaults,
		router: FeaturingRouter
	) {
		self.manager = manager
		self.storiesService = storiesService
		self.pushService = pushService
		self.dbAnalytics = dbAnalytics
		self.ud = ud
		self.router = router

//		self.reset()
	}

	func reset() {
		#if DEBUG
		self.dbAnalytics.reset()
		self.ud.reset()
		#endif
	}

	/// На старте загружаем данные, по готовности показываем фичеринг и шедулим пуш активной кампании
	public func applicationStart() {
		self.manager.refetchData { [weak self] _ in
			self?.scheduleApplicationStartFeaturing()
			self?.reschedulePushFeaturing()
			self?.subscribeOnDataUpdates()
		}

		/// Start app state tracking
		NotificationCenter.default.addObserver(
			forName: UIApplication.willResignActiveNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.applicationWillResignActive()
		}
		NotificationCenter.default.addObserver(
			forName: UIApplication.didBecomeActiveNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.applicationDidBecomeActive()
		}

		/// Track app start analytics
		let isFirstStart = !self.ud.didStartEarly
		if isFirstStart {
			self.ud.didStartEarly = true
			self.dbAnalytics.trackFirstLaunch()
		}

		self.dbAnalytics.trackApplicationStart()
		Anl.track { $0.name(.jetfire_application_start) }
	}

	private func applicationDidBecomeActive() {
		self.dbAnalytics.trackApplicationStart()
		Anl.track { $0.name(.jetfire_become_active) }
	}

	private func applicationWillResignActive() {
		self.dbAnalytics.trackApplicationStop()
		Anl.track { $0.name(.jetfire_resign_active) }

		self.dbAnalytics.flush(completion: { _ in })
//		self.pushService.scheduleActiveFeaturing { campaign in
//			self.manager.trackShow(campaign: campaign, featuringType: .push)
//
//			Anl.track { track in
//				track.name(.jetfire_featuring_trigger_show)
//					.param(.jetfire_featuring_id, value: campaign.id)
//					.param(.jetfire_trigger_type, value: String.kPush)
//			}
//		}
	}

	public func trackStart(feature: String) {
		self.dbAnalytics.trackFeatureOpen(feature: feature)
		self.reschedulePushFeaturing()
		self.rescheduleToasterFeaturing()

		Anl.track { track in
			track.name(.jetfire_feature_start)
				.param(.jetfire_featuring_id, value: feature)
		}
	}

	public func trackFinish(feature: String) {
		self.dbAnalytics.trackFeatureUse(feature: feature)
		self.reschedulePushFeaturing()

		Anl.track { track in
			track.name(.jetfire_feature_finish)
				.param(.jetfire_featuring_id, value: feature)
		}
	}

	public func updatePushStatus(granted: Bool) {
		self.pushService.update(granted: granted)
	}

	/// MARK: Private
	/// При обновлении статуса пуш-нотификаций дёргается метод и перенастраивает пуш-компанию на следующую непоказанную
	private func reschedulePushFeaturing() {
//		guard self.pushService.isGranted else {
//			self.pushService.removeAllFeaturings()
//			return
//		}
//
//		self.pushService.resetPreparingFeaturing()
//		guard let campaign = self.manager.campaignForPush() else { return }
//		self.pushService.prepareFeaturing(campaign: campaign.campaign)
	}

	private func rescheduleToasterFeaturing() {
		self.manager.prepareTriggeredCampaigns()
		if let campaign = self.manager.campaignForToaster() {
			self.showToaster(campaign: campaign)
		}
	}

	private func scheduleApplicationStartFeaturing() {
		self.manager.prepareAvailableCampaigns()
		if let campaign = self.manager.campaignForApplicationStart() {
			self.show(campaign: campaign, featuringType: .applicationStart)
		}
	}

	private func show(campaign: FeaturingCampaignAndStory, featuringType: FeaturingCampaign.FeaturingType) {
		self.manager.trackShow(campaign: campaign.campaign, featuringType: featuringType)
		Anl.track { track in
			track.name(.jetfire_featuring_campaign_show)
				.param(.jetfire_featuring_type, value: featuringType.rawValue)
				.param(.jetfire_featuring_id, value: campaign.campaign.id)
		}
		self.storiesService.show(story: campaign.story, in: [campaign.story])
	}

	private func showToaster(campaign: FeaturingCampaignAndStory) {
		self.router.showToaster(style: .button(
			title: campaign.campaign.toaster.title,
			button: campaign.campaign.toaster.actionButton.title,
			completion: { [weak self] in
				self?.show(campaign: campaign, featuringType: .toaster)
			}))
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
