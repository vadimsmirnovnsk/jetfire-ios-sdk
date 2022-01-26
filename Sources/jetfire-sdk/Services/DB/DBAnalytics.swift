// Класс для трекинга событий аналитики в базу данных и синхронизации этих данных с бэком

import Foundation
import VNEssential
import UIKit

//	event_type – интовый id события из протобафовского EventType
//	custom_event – если тип события кастомный, то тут имя этого кастомного события
//	event_uuid – рандомно сгенерированный UUID
//	feature – текстовое имя фичи
//	campaign_id, feature_id, entity_id – данные из фичеринга, если есть
//	date, timestamp – отдельно поле с датой без времени для удобства и поле с полным таймстемпом события
//	data – поле текстовое, чтобы хранить например, json с дополнительными параметрами

enum DBEventType: Int {
	 case custom = 0
	 case first_launch = 1
	 case application_start = 2
	 case application_shutdown = 3
	 case feature_open = 4
	 case feature_close = 5
	 case feature_use = 6
	 case story_open = 7
	 case story_tap = 8
	 case story_close = 9
	 case push_show = 10
	 case push_tap = 11
	 case push_close = 12
	 case toaster_show = 13
	 case toaster_tap = 14
	 case toaster_close = 15
	 case feature_accepted = 16
}

// MARK: - DBAnalytics

final class DBAnalytics {

	private let db: DB!
	private let ud: IUserSettings
	private let api: IFeaturingAPI

    let onChanged: Event<Void> = Event()

	init(ud: IUserSettings, api: IFeaturingAPI) {
		self.ud = ud
		self.api = api
		let url = FileManager.libraryPath(forFileName: "db-v1.sqlite3")!
		self.db = try! DB(path: url)
		print("Opened DB by path: \(url)")
	}

	func reset() {
		#if DEBUG
		try? self.db.remakeTables()
		#endif
	}

	func flush(completion: @escaping BoolBlock) {
		let since = self.ud.lastFlushDate ?? Date.distantPast
		let till = Date()
		let events = self.db.fetchEvents(since: since, till: till)

		let app = UIApplication.shared
		var taskId: UIBackgroundTaskIdentifier = .invalid
		let internalCompletion: VoidBlock = {
			if taskId != .invalid {
				app.endBackgroundTask(taskId)
				taskId = .invalid
			}
		}
		taskId = app.beginBackgroundTask {
			internalCompletion()
		}
		self.api.sync(events: events) { [weak self] res in
			switch res {
				case .failure(let error):
					print("💥 Jetfire sync data error: \(error)")
					completion(false)
					internalCompletion()
				case .success:
					print("Jetfire synced data ad: \(till)")
					self?.ud.lastFlushDate = till
					completion(true)
					internalCompletion()
			}
		}
	}

	func execute(sql: String) -> [Int64] {
		self.db.fetch(sql: sql)
	}

	func track(
		eventType: DBEventType,
		campaignId: Int64? = nil,
		feature: String? = nil,
		featureId: Int? = nil,
		entityId: String? = nil,
		customEvent: String? = nil,
		data: Data? = nil
	) {
		let date = Date()
		let event = DBEvent(
			id: nil,
			event_type: eventType.rawValue,
			custom_event: customEvent,
			event_uuid: UUID().uuidString,
			campaign_id: campaignId,
			feature: feature,
			feature_id: featureId,
			entity_id: entityId,
			date: DateFormatter.db_yyyy_mm_dd.string(from: date),
			timestamp: date,
			data: data
		)
		self.db.track(event: event)
        self.onChanged.raise(())
	}

}
