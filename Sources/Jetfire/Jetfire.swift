import Foundation
import UserNotifications
import UIKit
import VNBase

public class Jetfire {

	public static var mode: JetfireMode = .production
	public static let standard = Jetfire()

	public var cover: CoverStyle = .delo()
	public var toast: ToastStyle = .delo()
	public var snap: SnapStyle = .delo()
	/// Визуальный стиль — какая подложка (для адаптации к светлой/тёмной теме на лету, например)
	public var toastVisualStyle: ToastVisualStyle = .blur(.systemChromeMaterialDark)

    public var onLogEvent: ((_ name: EventId, _ params: [ParameterId: Any]) -> Void)? {
        get { self.container.analytics.onLogEvent }
        set { self.container.analytics.onLogEvent = newValue }
    }

	private var isStarted = false

	private(set) lazy var router = FeaturingRouter(container: self)
    private lazy var container: JetfireContainer = {
		JetfireContainer(router: router, mode: Jetfire.mode)
    }()

    private init() {}

	public func start() {
		self.isStarted = true
        self.container.jetfireMain.start()
	}

    public func enableFeaturing() {
        self.checkStarted()
        self.container.jetfireMain.enableFeaturing()
    }

    public func reset() {
        self.container.jetfireMain.reset()
    }

    public func appendLogTracker(_ tracker: IJetfireLogTracker) {
        self.container.logger.appendTracker(tracker)
    }

	public func storiesView() -> UIView {
        let vm = ContentStoriesVM(storiesService: self.container.storiesService)
		let view = ContentStoriesView()
		view.viewModel = vm
		return view
	}

}

// MARK: - Analytics

public extension Jetfire {

    func trackStart(feature: String) {
        self.checkStarted()
        self.container.featuring.trackStart(feature: feature)
    }

    func trackFinish(feature: String) {
        self.checkStarted()
        self.container.featuring.trackFinish(feature: feature)
    }

    func logEvent(_ name: String) {
        self.checkStarted()
        self.container.externalAnalyticsService.logEvent(name)
    }

    func setUserProperty(_ value: Any, forName name: String) {
        self.checkStarted()
        self.container.externalAnalyticsService.setUserProperty(value, forName: name)
    }

    func removeUserProperty(forName name: String) {
        self.checkStarted()
        self.container.externalAnalyticsService.removeUserProperty(forName: name)
    }

    func setSessionProperty(_ value: Any, forName name: String) {
        self.checkStarted()
        self.container.externalAnalyticsService.setSessionProperty(value, forName: name)
    }

    func removeSessionProperty(forName name: String) {
        self.checkStarted()
        self.container.externalAnalyticsService.removeSessionProperty(forName: name)
    }
}

// MARK: - Private

private extension Jetfire {

    func checkStarted() {
        guard !self.isStarted else { return }
        fatalError("You must call 'start' first")
    }
}
