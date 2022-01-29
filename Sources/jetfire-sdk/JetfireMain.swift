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
    private let dbAnalytics: DBAnalytics
    private var started: Bool = false

    init(
        ud: IUserSettings,
        analytics: JetfireAnalytics,
        storiesDataSource: IMutableStoriesDataSource,
        scheduler: IFeaturingScheduler,
        dbAnalytics: DBAnalytics
    ) {
        self.ud = ud
        self.analytics = analytics
        self.storiesDataSource = storiesDataSource
        self.scheduler = scheduler
        self.dbAnalytics = dbAnalytics
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        self.storiesDataSource.start()
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
        self.dbAnalytics.flush(completion: { _ in })
    }
}
