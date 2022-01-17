import Foundation
import UIKit

/// Запускает работу основных сервисов
protocol IJetfireMain {
    func start()
}

// MARK: - JetfireCoordinator

final class JetfireMain: IJetfireMain {

    private let ud: IFUserDefaults
    private let analytics: JetfireAnalytics
    private let scheduler: IFeaturingScheduler
    private var started: Bool = false

    init(ud: IFUserDefaults, analytics: JetfireAnalytics, scheduler: IFeaturingScheduler) {
        self.ud = ud
        self.analytics = analytics
        self.scheduler = scheduler
    }

    func start() {
        guard !self.started else { return }
        self.started = true
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
    }
}