import Foundation
import UIKit

/// Запускает работу основных сервисов
protocol IJetfireMain {
    func start()
    func enableFeaturing()
    func reset()
}

// MARK: - JetfireMain

final class JetfireMain: IJetfireMain {

    private let ud: IUserSettings
    private let analytics: JetfireAnalytics
    private let storiesDataSource: IMutableStoriesDataSource
    private let scheduler: IFeaturingScheduler
    private let databaseService: IDatabaseService
    private let storiesCampaignsProvider: IStoriesCampaignsProvider
    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let eventsFlusherService: IEventsFlusherService
    private let logger: ILoggerService
    private var started: Bool = false

    init(
        ud: IUserSettings,
        analytics: JetfireAnalytics,
        storiesDataSource: IMutableStoriesDataSource,
        scheduler: IFeaturingScheduler,
        databaseService: IDatabaseService,
        storiesCampaignsProvider: IStoriesCampaignsProvider,
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        eventsFlusherService: IEventsFlusherService,
        logger: ILoggerService
    ) {
        self.ud = ud
        self.analytics = analytics
        self.storiesDataSource = storiesDataSource
        self.scheduler = scheduler
        self.databaseService = databaseService
        self.storiesCampaignsProvider = storiesCampaignsProvider
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.eventsFlusherService = eventsFlusherService
        self.logger = logger
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        Log.info("Jetfire started")
        self.databaseService.start()
        let isFirstStart = !self.ud.didStartEarly
        if isFirstStart {
            self.ud.didStartEarly = true
            self.analytics.trackFirstLaunch()
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applicationWillResignActive()
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }
    }

    func enableFeaturing() {
        Log.info("Enable featuring")
        self.storiesCampaignsProvider.start()
        self.triggeredCampaignsProvider.start()
        self.scheduler.start()
    }

    func reset() {
        Log.info("Will reset all internal state and storage")
        self.ud.reset()
        self.databaseService.reset()
    }
}

// MARK: - Private

extension JetfireMain {

    private func applicationDidBecomeActive() {
        self.analytics.trackApplicationStart()
    }

    private func applicationWillResignActive() {
        self.analytics.trackApplicationShutdown()
        self.eventsFlusherService.flush()
    }
}
