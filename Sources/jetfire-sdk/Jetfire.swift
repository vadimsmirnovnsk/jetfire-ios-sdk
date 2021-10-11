import Foundation

public class Jetfire {

	public static let standard = Jetfire()

	internal static var analytics: StoriesAnalytics { Jetfire.standard.storiesConfig.analytics }

	public let storiesConfig: StoriesConfig
	public let firebaseConfig: FirebaseConfig
	public let featuringConfig: FeaturingConfig

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

}
