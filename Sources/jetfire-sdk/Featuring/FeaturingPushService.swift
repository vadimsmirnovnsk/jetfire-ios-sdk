import VNEssential
import UserNotifications
import UserNotificationsUI
import Foundation

/// Этот объект запоминает/обновляет кампанию для пуша и когда надо шедулит
final class FeaturingPushService {

	let onGrantedEvent = Event<Bool>()

	private let ud: IUserSettings
	private let analytics: IJetfireAnalytics
	private let notificationCenter = UNUserNotificationCenter.current()
	private let localPushService: FeaturingLocalNotificationService

	private(set) var isGranted = false {
		didSet {
			self.onGrantedEvent.raise(self.isGranted)
		}
	}

	private var preparingCampaign: JetFireCampaign?
	private var after: TimeInterval?

	init(ud: IUserSettings, analytics: IJetfireAnalytics) {
		self.ud = ud
		self.analytics = analytics
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
		self.analytics.setUserProperty(String(granted), forName: ParameterId.jetfire_push_notifications.rawValue)
	}

	func removeAllFeaturings() {
		self.notificationCenter.removeDeliveredNotifications(withIdentifiers: self.ud.pendingNotificationIds)
		self.ud.pendingNotificationIds = []
	}

	func resetPreparingFeaturing() {
		self.preparingCampaign = nil
		self.after = nil
		print("Did reset push promo")
	}

	func prepareFeaturing(campaign: JetFireCampaign, after: TimeInterval) {
		self.preparingCampaign = campaign
		self.after = after
		print("Did prepare for push promo campaign id: \(campaign.id) after: \(after)")
	}

	func schedulePreparedPush() {
		guard let campaign = self.preparingCampaign, let after = after else { return }
		self.localPushService.schedulePush(for: campaign, afterInterval: after)
		self.ud.pendingNotificationIds.append(campaign.id.string)
	}

	func campaignId(from response: UNNotificationResponse) -> String {
		let id = response.notification.request.identifier
		self.ud.pendingNotificationIds.removeAll(where: { $0 == id })
		return id
	}

}
