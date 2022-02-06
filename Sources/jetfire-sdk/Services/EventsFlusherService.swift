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

    init(userSettings: IUserSettings, api: IFeaturingAPI, databaseService: IDatabaseService) {
        self.userSettings = userSettings
        self.api = api
        self.databaseService = databaseService
    }

    func flush() {
        let from = self.userSettings.lastFlushDate ?? Date.distantPast
        let dbEvents = self.databaseService.selectEvents(from: from)
        let to = Date()

        let app = UIApplication.shared
        var taskId: UIBackgroundTaskIdentifier = .invalid
        let completion: () -> Void = {
            if taskId != .invalid {
                app.endBackgroundTask(taskId)
                taskId = .invalid
            }
        }
        taskId = app.beginBackgroundTask {
            completion()
        }

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
            switch res {
            case .failure(let error):
                Log.info("💥 Sync data error: \(error)")
                completion()
            case .success:
                Log.info("Synced data from '\(from)' to '\(to)'")
                self?.userSettings.lastFlushDate = to
                completion()
            }
        }
    }
}
