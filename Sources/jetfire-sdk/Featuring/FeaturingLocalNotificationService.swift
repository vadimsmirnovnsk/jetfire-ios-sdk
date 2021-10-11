import VNEssential
import UserNotifications
import UserNotificationsUI

/// Этот объект шедулит пуши
final class FeaturingLocalNotificationService {

	private static let kIsFeaturingKey = "isFeaturingLocalNotification"
	private static let kFeaturingIdKey = "featuringId"
	private static let kFeaturingThreadIdentifier = "featuring"
	private static let kPushInteravl: TimeInterval = 3

	private let localNotificationsCenter: UNUserNotificationCenter

	init(localNotificationsCenter: UNUserNotificationCenter) {
		self.localNotificationsCenter = localNotificationsCenter
	}

	func schedulePush(for campaign: FeaturingCampaign) {
		guard let push = campaign.push else { return }

		let userInfo: [AnyHashable : Any] = [
			Self.kIsFeaturingKey: true,
			Self.kFeaturingIdKey: campaign.id
		]

		self.schedulePush(
			title: push.title,
			subtitle: push.subtitle,
			message: push.body,
			date: Date(timeIntervalSinceNow: Self.kPushInteravl),
			id: campaign.id,
			threadIdentifier: Self.kFeaturingThreadIdentifier,
			userInfo: userInfo
		)
	}

	func schedulePush(
		title: String,
		subtitle: String?,
		message: String,
		date: Date,
		id: String,
		threadIdentifier: String,
		userInfo: [AnyHashable : Any])
	{
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = message
		content.sound = .default
		content.userInfo = userInfo
		content.threadIdentifier = threadIdentifier
		if let subtitle = subtitle {
			content.subtitle = subtitle
		}

		let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

		self.localNotificationsCenter.add(request) { error in
			if let error = error {
				print("Notification Error: \(error)")
			}
		}
	}

}
