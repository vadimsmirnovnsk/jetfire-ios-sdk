import Foundation
import SQLite
import VNBase

extension DB {

	public func track(event: DBEvent) {
        do {
            let eventId = try self.insertEvent(event)
            Log.info("Inserted event with id: \(eventId)")
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
	}

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

public class DB {

	private let db: Connection

	private let id = Expression<Int64>(DBEvent.CodingKeys.id.rawValue)
	private let event_type = Expression<Int64>(DBEvent.CodingKeys.event_type.rawValue)
	private let custom_event = Expression<String?>(DBEvent.CodingKeys.custom_event.rawValue)
	private let event_uuid = Expression<String>(DBEvent.CodingKeys.event_uuid.rawValue)
	private let campaign_id = Expression<Int64?>(DBEvent.CodingKeys.campaign_id.rawValue)
	private let feature = Expression<String?>(DBEvent.CodingKeys.feature.rawValue)
	private let feature_id = Expression<Int64?>(DBEvent.CodingKeys.feature_id.rawValue)
	private let entity_id = Expression<String?>(DBEvent.CodingKeys.entity_id.rawValue)
	private let date = Expression<String>(DBEvent.CodingKeys.date.rawValue)
	private let timestamp = Expression<Date>(DBEvent.CodingKeys.timestamp.rawValue)
	private let data = Expression<Data?>(DBEvent.CodingKeys.data.rawValue)
	private let events = Table("events")

	public init(path: URL) throws {
		self.db = try Connection(path.path)
		try self.makeTables()
	}

	func fetchEvents(since: Date, till: Date) -> [JetFireEvent] {
        do {
            let query = self.events.select(*)
                .where(timestamp >= since)
                .where(timestamp <= till)
            let events = try self.db.prepare(query)
            let es = events.map { e in
                JetFireEvent.with {
                    $0.uuid = e[event_uuid]
                    $0.timestamp = e[timestamp].timeIntervalSince1970.timestamp
                    $0.eventType = e[event_type].eventType
                    if let ce = e[custom_event] {
                        $0.customEvent = ce
                    }
                    if let f = e[feature] {
                        $0.feature = f
                    }
                    if let cid = e[campaign_id] {
                        $0.campaignID = cid
                    }
                    #warning("Переделать, когда изменится протобаф")
                    if let eid = Int64(e[entity_id] ?? "") {
                        $0.entityID = eid
                    }
                    #warning("Add properties")
                }
            }
            return es
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
	}

	func makeTables() throws {
		try db.run(events.create(ifNotExists: true) { t in
			t.column(id, primaryKey: true)
			t.column(event_type)
			t.column(custom_event)
			t.column(event_uuid)
			t.column(campaign_id)
			t.column(feature)
			t.column(feature_id)
			t.column(entity_id)
			t.column(date)
			t.column(timestamp)
			t.column(data)
		})
	}

	func remakeTables() throws {
		#if DEBUG
		// от греха подальше
		_ = try? db.run(events.drop())
		try self.makeTables()
		#endif
	}

	func fetch(sql: String) -> [Int64] {
        do {
            let stmt = try self.db.prepare(sql)
            return stmt.flatMap { $0 }.compactMap { $0 as? Int64 }
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
	}

	private func insertEvent(_ event: DBEvent) throws -> Int64 {
		let insert = try events.insert(event, userInfo: [:])
		let eventId = try db.run(insert)
		return eventId
	}

}

extension Connection {
	public var userVersion: Int32 {
		get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
		set { try! run("PRAGMA user_version = \(newValue)") }
	}
}
