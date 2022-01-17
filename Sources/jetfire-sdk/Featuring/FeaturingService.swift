import UserNotifications
import UIKit

/// Класс — точка входа на фичеринг снаружи.
///
/// Он получает решения от фичеринг менеджера и показывает фичеринг, трекает события фичеринга,
/// управляет кругляшами в сториз карусели
final public class FeaturingService {

	private let manager: FeaturingManager
	private let pushService: FeaturingPushService
	private let db: DBAnalytics
	private let ud: IFUserDefaults
	private let scheduler: StoryScheduler
	private let analytics: JetfireAnalytics

	init(
		manager: FeaturingManager,
		pushService: FeaturingPushService,
		db: DBAnalytics,
		ud: IFUserDefaults,
		scheduler: StoryScheduler,
		analytics: JetfireAnalytics
	) {
		self.manager = manager
		self.pushService = pushService
		self.db = db
		self.scheduler = scheduler
		self.ud = ud
		self.analytics = analytics

//		self.reset()
	}

	func reset() {
		#if DEBUG
		self.db.reset()
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
			self.analytics.trackFirstLaunch()
		}

		self.analytics.trackApplicationStart()
	}

	private func applicationDidBecomeActive() {
		self.analytics.trackApplicationStart()
		self.dbDidModify()
	}

	private func applicationWillResignActive() {
		self.analytics.trackApplicationShutdown()
		self.dbDidModify()
		/// Решедулим пуши только при выходе из приложения
		self.reschedulePushFeaturing()

		self.db.flush(completion: { _ in })
	}

	public func trackStart(feature: String) {
		self.analytics.trackFeatureOpen(feature: feature)
		self.dbDidModify()
	}

	public func trackFinish(feature: String) {
		self.analytics.trackFeatureUse(feature: feature)
		self.dbDidModify()
	}

	public func updatePushStatus(granted: Bool) {
		self.pushService.update(granted: granted)
	}

	/// MARK: Private
	/// Это главная функция, которая дёргается на каждый чих в приложении, чтобы бросать в пользователя фичеринги
	private func dbDidModify() {
		/// Чтобы появились новые сториз в карусели
		self.manager.prepareAvailableCampaigns()
		/// И чтобы появились новые кампании для тостера/пуша
		self.manager.prepareTriggeredCampaigns()
		/// Решедулим тостер с новыми событиями в базе
		self.rescheduleToasterFeaturing()
	}

	/// При обновлении статуса пуш-нотификаций дёргается метод и перенастраивает пуш-компанию на следующую непоказанную
	private func reschedulePushFeaturing() {
		guard let campaign = self.manager.campaignForPush() else { return }
		self.scheduler.schedulePush(campaign: campaign)
	}

	private func rescheduleToasterFeaturing() {
		if let campaign = self.manager.campaignForToaster() {
			self.scheduler.scheduleToaster(campaign: campaign)
		}
	}

	private func scheduleApplicationStartFeaturing() {
		self.manager.prepareAvailableCampaigns()
		if let campaign = self.manager.campaignForApplicationStart() {
			self.scheduler.scheduleShow(campaign: campaign, featuringType: .applicationStart)
		}
	}

	private func subscribeOnDataUpdates() {
		self.manager.onFeaturingUpdated.add(self) { [weak self] _ in
			self?.dbDidModify()
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
		self.analytics.trackPushTap(campaignId: Int(campaignId))
		self.manager.retreiveCampaign(with: campaignId) { [weak self] campaign in
			guard let campaign = campaign else { return }
			self?.scheduler.scheduleShow(campaign: campaign, featuringType: .push)
		}
	}

}
