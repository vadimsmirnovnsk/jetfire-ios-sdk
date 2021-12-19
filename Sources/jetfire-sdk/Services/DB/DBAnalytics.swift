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
	 case first_launch
	 case application_start
	 case application_shutdown
	 case feature_open
	 case feature_close
	 case feature_use
	 case story_open
	 case story_tap
	 case story_close
	 case push_show
	 case push_tap
	 case push_close
	 case toaster_show
	 case toaster_tap
	 case toaster_close
	 case feature_accepted
}

final class DBAnalytics {

	private let db: DB!
	private let ud: IFUserDefaults
	private let api: IFeaturingAPI

	init(ud: IFUserDefaults, api: IFeaturingAPI) {
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
		campaignId: Int? = nil,
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
	}

}
