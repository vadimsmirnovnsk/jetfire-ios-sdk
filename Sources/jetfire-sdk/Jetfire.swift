import Foundation
import UserNotifications

public class Jetfire {

	public static let standard = Jetfire()

	internal static var analytics: StoriesAnalytics { Jetfire.standard.storiesConfig.analytics }

	public let storiesConfig: StoriesConfig
	public let firebaseConfig: FirebaseConfig
	private let featuringConfig: FeaturingConfig

	private let api = APIService()
	private let ud = UserDefaults.standard

    public init() {
		let analytics: [IAnalytics] = [] // [ FirebaseAnalytics() ]

		self.storiesConfig = StoriesConfig(analytics: analytics)
		self.firebaseConfig = FirebaseConfig(api: self.api, ud: self.ud)
		self.featuringConfig = FeaturingConfig(
			api: self.api,
			ud: self.ud,
			storiesService: self.firebaseConfig.storiesService,
			userUUID: UUID().uuidString
		)
    }

	public func applicationStart() {
		self.featuringConfig.featuring.applicationStart()
	}

	public func applicationDidBecomeActive() {
		self.featuringConfig.featuring.applicationDidBecomeActive()
	}

	public func applicationWillResignActive() {
		self.featuringConfig.featuring.applicationWillResignActive()
	}

	public func trackStart(feature: String) {
		self.featuringConfig.featuring.trackStart(feature: feature)
	}

	public func trackFinish(feature: String) {
		self.featuringConfig.featuring.trackFinish(feature: feature)
	}

	public func updatePushStatus(granted: Bool) {
		self.featuringConfig.featuring.updatePushStatus(granted: granted)
	}

	public func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) {
		self.featuringConfig.featuring.userNotificationCenter(center, didReceive: response)
	}

}
