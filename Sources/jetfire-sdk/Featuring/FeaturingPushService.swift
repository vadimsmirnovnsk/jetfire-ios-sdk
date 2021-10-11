import VNEssential
import UserNotifications
import UserNotificationsUI

/// Этот объект запоминает/обновляет кампанию для пуша и когда надо шедулит
final class FeaturingPushService {

	let onGrantedEvent = Event<Bool>()

	private let ud: IFUserDefaults
	private let notificationCenter = UNUserNotificationCenter.current()
	private let localPushService: FeaturingLocalNotificationService

	private(set) var isGranted = false {
		didSet {
			self.onGrantedEvent.raise(self.isGranted)
		}
	}

	private var preparingCampaign: FeaturingCampaign?

	init(ud: IFUserDefaults) {
		self.ud = ud
		self.localPushService = FeaturingLocalNotificationService(localNotificationsCenter: self.notificationCenter)

		self.notificationCenter.getNotificationSettings { [weak self] settings in
			let granted =
				settings.soundSetting == .enabled ||
				settings.badgeSetting == .enabled ||
				settings.alertSetting == .enabled
			self?.update(granted: granted)
		}
	}

	func update(granted: Bool) {
		self.isGranted = granted
		Anl.trackUserProperties { track in
			track.param(.firetest_push_notifications, value: granted)
		}
	}

	func removeAllFeaturings() {
		self.notificationCenter.removeDeliveredNotifications(withIdentifiers: self.ud.pendingNotificationIds)
		self.ud.pendingNotificationIds = []
	}

	func prepareFeaturing(campaign: FeaturingCampaign) {
		self.preparingCampaign = campaign
		print("Did prepare for push promo featuring id: \(campaign.id)")
	}

	func resetPreparingFeaturing() {
		self.preparingCampaign = nil
		print("Did reset push promo")
	}

	func scheduleActiveFeaturing(completion: (FeaturingCampaign) -> Void) {
		guard let campaign = self.preparingCampaign else { return }
		self.localPushService.schedulePush(for: campaign)
		self.ud.pendingNotificationIds.append(campaign.id)
		completion(campaign)
	}

	func campaignId(from response: UNNotificationResponse) -> String {
		let id = response.notification.request.identifier
		self.ud.pendingNotificationIds.removeAll(where: { $0 == id })
		return id
	}

}
