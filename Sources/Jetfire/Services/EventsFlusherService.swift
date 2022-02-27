import Foundation
import UIKit

protocol IEventsFlusherService {
    func flush()
}

// MARK: - EventsFlusherService

class EventsFlusherService: IEventsFlusherService {

    private let userSettings: IUserSettings
    private let databaseService: IDatabaseService
    private let api: IFeaturingAPI
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

    init(userSettings: IUserSettings, api: IFeaturingAPI, databaseService: IDatabaseService) {
        self.userSettings = userSettings
        self.api = api
        self.databaseService = databaseService
    }

    func flush() {
        DispatchQueue.jetfire.async {
            self.performFlush()
        }
    }
}

// MARK: - Private

extension EventsFlusherService {

    private func performFlush() {
        guard self.backgroundTaskId == .invalid else { return }
        let from = self.userSettings.lastFlushDate ?? Date.distantPast
        let dbEvents = self.databaseService.selectEvents(from: from)
        let to = Date()

        let taskId = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let self = self else { return }
            DispatchQueue.jetfire.async {
                Log.info("Sync data error: background task expired")
                self.endBackgroundTask()
            }
        }

        self.backgroundTaskId = taskId

        let events: [JetFireEvent] = dbEvents.map { event in
            JetFireEvent.with {
                $0.uuid = event.eventUuid
                $0.timestamp = event.timestamp.timeIntervalSince1970.timestamp
                $0.eventType = JetFireEventType.with {
                    $0.value = Int64(event.eventType.rawValue)
                }
                if let ce = event.customEvent {
                    $0.customEvent = ce
                }
                if let f = event.feature {
                    $0.feature = f
                }
                if let cid = event.campaignId {
                    $0.campaignID = cid
                }
                if let eid = Int64(event.entityId ?? "") {
                    $0.entityID = eid
                }
            }
        }
        
        self.api.sync(events: events) { [weak self] res in
            guard let self = self else { return }
            DispatchQueue.jetfire.async {
                switch res {
                case .failure(let error):
                    Log.info("Sync data error: \(error)")
                    self.endBackgroundTask()
                case .success:
                    Log.info("Synced data from '\(from)' to '\(to)'")
                    self.userSettings.lastFlushDate = to
                    self.endBackgroundTask()
                }
            }
        }
    }

    private func endBackgroundTask() {
        let id = self.backgroundTaskId
        guard id != .invalid else { return }
        self.backgroundTaskId = .invalid
        UIApplication.shared.endBackgroundTask(id)
    }
}
