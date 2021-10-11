import Foundation

public class Jetfire {

	public static let standard = Jetfire()

	internal static var analytics: StoriesAnalytics { Jetfire.standard.storiesConfig.analytics }

	public let storiesConfig = StoriesConfig()
	public let firebaseConfig: FirebaseConfig

	private let api: IAPIService = APIService()
	private let ud: IUserDefaults = UserDefaults.standard

    public init() {
		self.firebaseConfig = FirebaseConfig(api: self.api, ud: self.ud)
    }

}
