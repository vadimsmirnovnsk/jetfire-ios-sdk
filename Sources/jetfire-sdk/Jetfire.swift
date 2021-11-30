import Foundation
import UserNotifications
import UIKit
import VNBase

public class Jetfire {

	public static let standard = Jetfire()

	internal static var analytics: StoriesAnalytics { Jetfire.standard.storiesConfig.analytics }

	public let storiesConfig: StoriesConfig

	private let api: APIService
	private let router = BaseRouter()
	private let ud = UserDefaults.standard
	private let application = UIApplication.shared

	private let contentPresenter = ContentPresenter()
	internal let serviceInfo = ServiceInfo()

	private(set) lazy var deeplinkService: DeeplinkService = { [unowned self] in
		return DeeplinkService(serviceInfo: self.serviceInfo)
	}()

	private(set) lazy var processTargetService: ProcessTargetService = { [unowned self] in
		return ProcessTargetService(application: self.application, deeplinkService: self.deeplinkService)
	}()

	private(set) lazy var firebaseStorage: FirebaseStoriesStorage = { [unowned self] in
		return FirebaseStoriesStorage(processTargetService: self.processTargetService, router: self.router)
	}()

	private(set) lazy var snapsConfig: StoryTypesConfig = { [unowned self] in
		return StoryTypesConfig(
			api: self.api,
			ud: self.ud,
			storage: self.firebaseStorage,
			processTargetService: self.processTargetService,
			router: self.router
		)
	}()

	private(set) lazy var featuringConfig: FeaturingConfig = { [unowned self] in
		return FeaturingConfig(
			api: self.api,
			ud: self.ud,
			storiesService: self.snapsConfig.storiesService,
			userUUID: UUID().uuidString,
			dbAnalytics: self.dbAnalytics
		)
	}()

	private let preferences = PreferencesService()
	private let dbAnalytics = DBAnalytics()
	private let userSessionService: UserSessionService

    public init() {
		let analytics: [IAnalytics] = [] // [ FirebaseAnalytics(), BackendAnalytics() ]
		self.storiesConfig = StoriesConfig(analytics: analytics)
		self.userSessionService = UserSessionService(
			userId: self.preferences.userId,
			sessionId: self.preferences.sessionId
		)
		self.api = APIService(
			bearer: self.serviceInfo.apiKey,
			userSessionService: self.userSessionService
		)
		self.api.configure(forBaseUrlString: Constants.baseURL, overrideHeaders: [:])
		
		self.deeplinkService.delegate = self.contentPresenter
    }

	public func applicationStart() {
		self.featuringConfig.featuring.applicationStart()

		self.api.fetchCampaigns { campaigns in
			print(campaigns)
		}
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
