import Foundation
import SQLite
import VNBase

extension DB {

//	public func addWater(volumeL: Double, date: Date) throws {
//		let id = try dayId(for: date)
//		let dayWater = water.filter(dayId == id)
//		if try db.run(dayWater.update(volume <- volumeL)) > 0 { // 3. check the rowcount
////			log.info("💧update water: \(volumeL) at \(date)")
//		} else { // update returned 0 because there was no match
//			// 4. insert the word
//			let rowid = try db.run(water.insert([
//				volume <- volumeL,
//				dayId <- id,
//			]))
////			log.info("💧add water(\(rowid)): \(volumeL) at \(date)")
//		}
//	}
//
//	public func water(at date: Date) throws -> Double? {
//		let id = try dayId(for: date)
//		let row = try db.pluck(water.filter(dayId == id))
//		let volume = try row?.get(volume)
//		return volume
//	}

//	public func workouts(from date: Date, to: Date) throws -> [LocalWorkout] {
//		let ids = try self.dayIds(from: date, to: to)
//		guard !ids.isEmpty else { return [] }
//
//		let filter = workouts.filter(ids.contains(dayId))
//		let localWorkouts: [LocalWorkout] = try db.prepare(filter).map({ row -> LocalWorkout in
//			let workout: WorkoutDBO = try row.decode()
//			var metadata: [String : Any] = [:]
//			if let data = workout.data,
//			   let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//				metadata = object
//			}
//			return LocalWorkout(
//				id: try row.get(workoutId),
//				type: workout.type,
//				date: workout.date,
//				distance: workout.distance,
//				duration: workout.duration,
//				totalEnergyBurned: workout.calorie,
//				metadata: metadata
//			)
//		})
//		return localWorkouts
//	}
//
//	public func goals(from date: Date, to: Date) throws -> [GoalDTO] {
//		let ids = try self.dayIds(from: date, to: to)
//		guard !ids.isEmpty else { return [] }
//
//		let filter = goals.filter(ids.contains(dayId))
//		let localGoals: [GoalDTO] = try db.prepare(filter).map({ row -> GoalDTO in
//			GoalDTO(
//				date: try row.get(self.date),
//				type: try row.get(type),
//				value: try row.get(value)
//			)
//		})
//		return localGoals
//	}
//	public func goal(type: Int, at date: Date) throws -> GoalDTO? {
//		let id = try self.dayId(for: date)
//
//		let filter = goals.filter(id == dayId && type == self.type)
//		let localGoals: [GoalDTO] = try db.prepare(filter).map({ row -> GoalDTO in
//			GoalDTO(
//				date: try row.get(self.date),
//				type: try row.get(self.type),
//				value: try row.get(value)
//			)
//		})
//		assert(localGoals.count <= 1)
//		return localGoals.first
//	}
//
//	public func addGoal(_ goal: GoalDTO) throws {
//		let id = try dayId(for: goal.date)
//
//		let dayGoal = goals.filter(type == goal.type && dayId == id)
//		if try db.run(dayGoal.update(value <- goal.value)) > 0 { // 3. check the rowcount
//			// good job
//		} else { // update returned 0 because there was no match
//			// 4. insert the word
//			_ = try db.run(goals.insert([
//				date <- goal.date,
//				type <- goal.type,
//				value <- goal.value,
//				dayId <- id,
//			]))
//		}
//	}

//	public func deleteWorkout(id: Int64) throws {
//		let filter = workouts.filter(workoutId == id)
//		try db.run(filter.delete())
//	}
//
//	public func addWorkout(
//		_ workout: IWorkoutDTO
//	) throws -> Int64 {
//		var data: Data?
//		do {
//			data = try JSONSerialization.data(withJSONObject: workout.metadata, options: [])
//		} catch {
////			log.error("Decode error: \(error)")
//		}
//		let dbo = WorkoutDBO(
//			type: workout.type,
//			calorie: workout.totalEnergyBurned,
//			duration: workout.duration,
//			distance: workout.distance,
//			date: workout.date,
//			data: data
//		)
//		return try self.insertWorkout(dbo)
//	}
}

extension Date {
	var morning: Date {
		var components = Calendar.current.dateComponents([ .year, .month, .day, .hour, .minute, .second ], from: self)
		components.calendar = Calendar.current
		components.hour = 0
		components.minute = 0
		components.second = 1
		return components.date!
	}

	/// + 24 часа
	var nextDay: Date {
		self.appendingDays(1)
	}
	func appendingDays(_ count: Int) -> Date {
		Calendar.current.date(byAdding: .day, value: count, to: self)!
	}
}

public class DB {

	struct Events: Codable {
		let id: Int
		let event_type: Int
		let custom_event: String?
		let event_uuid: String
//		let date: Date
//		let data: Data?
		enum CodingKeys: String, CodingKey {
			case id
			case event_type
			case custom_event
			case event_uuid
		}
	}
//	CREATE TABLE "events"
//	(
//		"id"           INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
//		"event_type"   INTEGER                           NOT NULL,
//		"custom_event" VARCHAR(255)                      NULL,
//		"event_uuid"   VARCHAR(20)                       NOT NULL,
//		"campaign_id"  INTEGER                           NULL,
//		"feature"      VARCHAR(255)                      NULL,
//		"feature_id"   INTEGER                           NULL,
//		"entity_id"    INTEGER                           NULL,
//		"date"         DATE                                       DEFAULT CURRENT_TIMESTAMP NOT NULL,
//		"timestamp"    DATETIME                                   DEFAULT CURRENT_TIMESTAMP NOT NULL,
//		"data"         TEXT                              NULL
//	);
//
//	event_type – интовый id события из протобафовского EventType
//	custom_event – если тип события кастомный, то тут имя этого кастомного события
//	event_uuid – рандомно сгенерированный UUID
//	feature – текстовое имя фичи
//	campaign_id, feature_id, entity_id – данные из фичеринга, если есть
//	date, timestamp – отдельно поле с датой без времени для удобства и поле с полным таймстемпом события
//	data – поле текстовое, чтобы хранить например, json с дополнительными параметрами

	private let db: Connection
//	private let log: ILogger

	private let id = Expression<Int64>(Events.CodingKeys.id.rawValue)
	private let event_type = Expression<Double>(Events.CodingKeys.event_type.rawValue)
	private let custom_event = Expression<Double>(Events.CodingKeys.custom_event.rawValue)
	private let event_uuid = Expression<Double>(Events.CodingKeys.event_uuid.rawValue)
	private let events = Table("events")

	public init(path: URL) throws {
//		self.log = logger
		self.db = try Connection(path.path)
		try self.makeTables()
	}

	func makeTables() throws {
		try db.run(events.create(ifNotExists: true) { t in
			t.column(id, primaryKey: true)
			t.column(event_type)
			t.column(custom_event)
			t.column(event_uuid)
		})
	}

	func remakeTables() throws {
		#if DEBUG
		// от греха подальше
//		_ = try? db.run(water.drop())
//		_ = try? db.run(workouts.drop())
//		_ = try? db.run(days.drop())
//		_ = try? db.run(goals.drop())
//		try self.makeTables()
		#endif
	}

	private func insertEvent(_ event: Events) throws -> Int64 {
		let insert = try events.insert(event, userInfo: [:])
		let eventId = try db.run(insert)
		return eventId
	}

}

extension Date {
	func todayKey() -> Int {
		Int(self.morning.timeIntervalSince1970)
	}
}

extension Connection {
	public var userVersion: Int32 {
		get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
		set { try! run("PRAGMA user_version = \(newValue)") }
	}
}
