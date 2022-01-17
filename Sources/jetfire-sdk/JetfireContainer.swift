import Foundation
import UIKit

/// DI-контейнер с зависимостями
final class JetfireContainer {

    private let application = UIApplication.shared
    private let ud = UserDefaults.standard
    private let serviceInfo = ServiceInfo()
    private let preferences = PreferencesService()
    private let contentPresenter = ContentPresenter()
    private let router: FeaturingRouter

    lazy private(set) var featuringStorage: FeaturingStorage = {
        let storage = FeaturingStorage(
            api: self.api,
            processTargetService: self.processTargetService,
            router: self.router,
            analytics: self.analytics
        )
        storage.service = self.storiesService
        return storage
    }()

    lazy private(set) var featuringManager: FeaturingManager = {
        FeaturingManager(ud: self.ud, storage: self.featuringStorage, db: self.dbAnalytics)
    }()

    lazy private(set) var featuringPushService: FeaturingPushService = {
        FeaturingPushService(ud: self.ud, analytics: self.analytics)
    }()

    lazy private(set) var storiesService: StoriesService = {
        StoriesService(router: self.router, storage: self.storiesDataSource, ud: self.ud)
    }()

    lazy private(set) var scheduler: StoryScheduler = {
        StoryScheduler(
            router: self.router,
            storiesService: self.storiesService,
            pushService: self.featuringPushService,
            ud: self.ud
        )
    }()

    lazy private(set) var featuring: FeaturingService = {
        FeaturingService(
            manager: self.featuringManager,
            pushService: self.featuringPushService,
            db: self.dbAnalytics,
            ud: self.ud,
            scheduler: self.scheduler,
            analytics: self.analytics
        )
    }()

    lazy private(set) var analytics: JetfireAnalytics = {
        JetfireAnalytics(db: self.dbAnalytics)
    }()

    lazy private(set) var processTargetService: ProcessTargetService = {
        ProcessTargetService(application: self.application, deeplinkService: self.deeplinkService)
    }()

    lazy private(set) var deeplinkService: DeeplinkService = {
        let serivice = DeeplinkService(serviceInfo: self.serviceInfo)
        serivice.delegate = self.contentPresenter
        return serivice
    }()

    lazy private(set) var userSessionService: UserSessionService = {
        UserSessionService(
            userId: self.preferences.userId,
            sessionId: self.preferences.sessionId
        )
    }()

    lazy private(set) var api: IAPIService & IFeaturingAPI = {
        let service = APIService(
            bearer: self.serviceInfo.apiKey,
            userSessionService: self.userSessionService
        )
        service.configure(forBaseUrlString: Constants.baseURL, overrideHeaders: [:])
        return service
    }()

    lazy private(set) var dbAnalytics: DBAnalytics = {
        DBAnalytics(ud: self.ud, api: self.api)
    }()

    lazy private(set) var campaignsProvider: ICampaignsProvider = {
        CachedCampaignsProvider(
            campaignsProvider: CampaignsProvider(api: self.api)
        )
    }()

    lazy private(set) var triggeredCampaignsProvider: ITriggeredCampaignsProvider = {
        TriggeredCampaignsProvider(
            campaignsProvider: self.campaignsProvider,
            db: self.dbAnalytics
        )
    }()

    lazy private(set) var storiesFactory: StoriesFactory = {
       StoriesFactory(
            storiesAnalytics: self.analytics,
            processTargetService: self.processTargetService,
            router: self.router
        )
    }()

    lazy private(set) var storiesDataSource: IStoriesDataSource & IMutableStoriesDataSource = {
        StoriesDataSource(
            factory: self.storiesFactory
        )
    }()

    lazy private(set) var schedulerTaskFactory: SchedulerTaskFactory = {
        SchedulerTaskFactory(
            triggeredCampaignsProvider: self.triggeredCampaignsProvider,
            storiesDataSource: self.storiesDataSource
        )
    }()

    lazy private(set) var featuringScheduler: IFeaturingScheduler = {
        FeaturingScheduler(
            triggeredCampaignsProvider: self.triggeredCampaignsProvider,
            factory: self.schedulerTaskFactory
        )
    }()

    lazy private(set) var jetfireMain: IJetfireMain = {
        JetfireMain(
            ud: self.ud,
            analytics: self.analytics,
            scheduler: self.featuringScheduler
        )
    }()

    init(router: FeaturingRouter) {
        self.router = router
        self.storiesFactory.storyService = self.storiesService
    }
}
