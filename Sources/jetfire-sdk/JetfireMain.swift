import Foundation
import UIKit

/// Запускает работу основных сервисов
protocol IJetfireMain {
    func start()
}

// MARK: - JetfireMain

final class JetfireMain: IJetfireMain {

    private let ud: IUserSettings
    private let analytics: JetfireAnalytics
    private let storiesDataSource: IMutableStoriesDataSource
    private let scheduler: IFeaturingScheduler
    private let databaseService: IDatabaseService
    private let eventsFlusherService: IEventsFlusherService
    private var started: Bool = false

    init(
        ud: IUserSettings,
        analytics: JetfireAnalytics,
        storiesDataSource: IMutableStoriesDataSource,
        scheduler: IFeaturingScheduler,
        databaseService: IDatabaseService,
        eventsFlusherService: IEventsFlusherService
    ) {
        self.ud = ud
        self.analytics = analytics
        self.storiesDataSource = storiesDataSource
        self.scheduler = scheduler
        self.databaseService = databaseService
        self.eventsFlusherService = eventsFlusherService
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        self.databaseService.start()
        self.scheduler.start()
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
