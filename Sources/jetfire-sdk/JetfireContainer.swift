import Foundation
import UIKit

/// DI-контейнер с зависимостями
final class JetfireContainer {

    private let application = UIApplication.shared
    private let router: FeaturingRouter

    lazy private(set) var contentPresenter: ContentPresenter = {
        ContentPresenter()
    }()

    lazy private(set) var preferences: PreferencesService = {
        PreferencesService()
    }()

    lazy private(set) var plistSettingsService: IPlistSettingsService = {
        PlistSettingsService()
    }()

    lazy private(set) var logger: ILoggerService = {
        LoggerService()
    }()

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

    lazy private(set) var userSettings: IUserSettings = {
        UserSettings()
    }()

    lazy private(set) var featuringManager: FeaturingManager = {
        FeaturingManager(
            ud: self.userSettings,
            storage: self.featuringStorage,
            db: self.databaseService
        )
    }()

    lazy private(set) var featuringPushService: FeaturingPushService = {
        FeaturingPushService(ud: self.userSettings)
    }()

    lazy private(set) var storiesService: StoriesService = {
        StoriesService(
            router: self.router,
            storage: self.storiesDataSource,
            ud: self.userSettings
        )
    }()

    lazy private(set) var scheduler: StoryScheduler = {
        StoryScheduler(
            router: self.router,
            storiesService: self.storiesService,
            pushService: self.featuringPushService,
            ud: self.userSettings
        )
    }()

    lazy private(set) var featuring: FeaturingService = {
        FeaturingService(
            manager: self.featuringManager,
            pushService: self.featuringPushService,
            ud: self.userSettings,
            scheduler: self.scheduler,
            analytics: self.analytics
        )
    }()

    lazy private(set) var analytics: JetfireAnalytics = {
        JetfireAnalytics(db: self.databaseService)
    }()

    lazy private(set) var processTargetService: ProcessTargetService = {
        ProcessTargetService(application: self.application, deeplinkService: self.deeplinkService)
    }()

    lazy private(set) var deeplinkService: DeeplinkService = {
        let serivice = DeeplinkService(plistSettingsService: self.plistSettingsService)
        serivice.delegate = self.contentPresenter
        return serivice
    }()

    lazy private(set) var userSessionService: IUserSessionService = {
        UserSessionService(
            userId: self.preferences.userId,
            sessionId: self.preferences.sessionId,
            databaseService: self.databaseService
        )
    }()

    lazy private(set) var api: IAPIService & IFeaturingAPI = {
        let service = APIService(
            plistSettingsService: self.plistSettingsService,
            userSessionService: self.userSessionService
        )
        return service
    }()

    lazy private(set) var campaignsProvider: ICampaignsProvider = {
        CachedCampaignsProvider(
            campaignsProvider: CampaignsProvider(api: self.api)
        )
    }()

    lazy private(set) var storiesCampaignsProvider: IStoriesCampaignsProvider = {
        StoriesCampaignsProvider(
            campaignsProvider: self.campaignsProvider,
            db: self.databaseService
        )
    }()

    lazy private(set) var triggeredCampaignsProvider: ITriggeredCampaignsProvider = {
        TriggeredCampaignsProvider(
            campaignsProvider: self.campaignsProvider,
            db: self.databaseService
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
            storiesCampaignsProvider: self.storiesCampaignsProvider,
            factory: self.storiesFactory
        )
    }()

    lazy private(set) var toasterFactory: ToasterFactory = {
        ToasterFactory(
            storiesService: self.storiesService,
            storiesFactory: self.storiesFactory,
            jetfireAnalytics: self.analytics
        )
    }()

    lazy private(set) var rulesProvider: IFeaturingRulesProvider = {
        FeaturingRulesProvider()
    }()

    lazy private(set) var schedulerTaskFactory: SchedulerTaskFactory = {
        SchedulerTaskFactory(
            triggeredCampaignsProvider: self.triggeredCampaignsProvider,
            storiesDataSource: self.storiesDataSource,
            toasterFactory: self.toasterFactory,
            jetfireAnalytics: self.analytics,
            ud: self.userSettings,
            rulesProvider: self.rulesProvider
        )
    }()

    lazy private(set) var featuringScheduler: IFeaturingScheduler = {
        FeaturingScheduler(
            storiesCampaignsProvider: self.storiesCampaignsProvider,
            triggeredCampaignsProvider: self.triggeredCampaignsProvider,
            factory: self.schedulerTaskFactory,
            userSettings: self.userSettings
        )
    }()

    lazy private(set) var databaseService: IDatabaseService = {
        DatabaseService()
    }()

    lazy private(set) var eventsFlusherService: IEventsFlusherService = {
        EventsFlusherService(
            userSettings: self.userSettings,
            api: self.api,
            databaseService: self.databaseService
        )
    }()

    lazy private(set) var externalAnalyticsService: IExternalAnalyticsService = {
        ExternalAnalyticsService(databaseService: self.databaseService)
    }()

    lazy private(set) var jetfireMain: IJetfireMain = {
        JetfireMain(
            ud: self.userSettings,
            analytics: self.analytics,
            storiesDataSource: self.storiesDataSource,
            scheduler: self.featuringScheduler,
            databaseService: self.databaseService,
            eventsFlusherService: self.eventsFlusherService
        )
    }()

    init(router: FeaturingRouter) {
        self.router = router
        LoggerContainer.logger = self.logger
        self.storiesFactory.storiesService = self.storiesService
    }
}
