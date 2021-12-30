import Foundation
import UserNotifications
import UIKit
import VNBase

public class Jetfire {

	public static let standard = Jetfire()

	public private(set) lazy var analytics: JetfireAnalytics = { [unowned self] in
		return JetfireAnalytics(db: self.dbAnalytics)
	}()

	public let storiesConfig = StoriesConfig()
	public var cover = CoverStyle.delo()
	public let snapsConfig = StoryTypesConfig()

	private let api: APIService
	private let ud = UserDefaults.standard
	private let application = UIApplication.shared
	private let contentPresenter = ContentPresenter()
	private let serviceInfo = ServiceInfo()
	private let preferences = PreferencesService()
	private let userSessionService: UserSessionService
	private var userUuid = UUID().uuidString

	private(set) lazy var router = FeaturingRouter(container: self)

	private lazy var deeplinkService: DeeplinkService = { [unowned self] in
		return DeeplinkService(serviceInfo: self.serviceInfo)
	}()

	private lazy var dbAnalytics: DBAnalytics = { [unowned self] in
		return DBAnalytics(ud: self.ud, api: self.api)
	}()

	private lazy var processTargetService: ProcessTargetService = { [unowned self] in
		return ProcessTargetService(application: self.application, deeplinkService: self.deeplinkService)
	}()

	private lazy var featuringStorage: FeaturingStorage = { [unowned self] in
		return FeaturingStorage(
			api: self.api,
			processTargetService: self.processTargetService,
			router: self.router,
			analytics: self.analytics
		)
	}()

	private lazy var featuringManager: FeaturingManager = { [unowned self] in
		return FeaturingManager(ud: self.ud, storage: self.featuringStorage, db: self.dbAnalytics)
	}()

	private lazy var featuringPushService: FeaturingPushService = { [unowned self] in
		return FeaturingPushService(ud: self.ud, analytics: self.analytics)
	}()

	private lazy var storiesService: StoriesService = { [unowned self] in
		return StoriesService(router: self.router, storage: self.featuringStorage, ud: self.ud)
	}()

	private lazy var scheduler: StoryScheduler = { [unowned self] in
		return StoryScheduler(
			router: self.router,
			storiesService: self.storiesService,
			pushService: self.featuringPushService,
			ud: self.ud
		)
	}()

	private(set) lazy var featuring: FeaturingService = { [unowned self] in
		return FeaturingService(
			manager: self.featuringManager,
			pushService: self.featuringPushService,
			db: self.dbAnalytics,
			ud: self.ud,
			scheduler: self.scheduler,
			analytics: self.analytics
		)
	}()

    public init() {
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

	public func start(with userUuid: String) {
		self.userUuid = userUuid
		self.featuring.applicationStart()
	}

	public func trackStart(feature: String) {
		self.featuring.trackStart(feature: feature)
	}

	public func trackFinish(feature: String) {
		self.featuring.trackFinish(feature: feature)
	}

	public func updatePushStatus(granted: Bool) {
		self.featuring.updatePushStatus(granted: granted)
	}

	public func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) {
		self.featuring.userNotificationCenter(center, didReceive: response)
	}

	public func storiesView() -> UIView {
		let vm = ContentStoriesVM(storiesService: self.storiesService)
		let view = ContentStoriesView()
		view.viewModel = vm
		return view
	}

	/// Container
	internal func toaster(style: ToasterView.Style, visualStyle: ToasterView.VisualStyle) -> ToasterView {
		return ToasterView(style: style, visualStyle: visualStyle)
	}

}
