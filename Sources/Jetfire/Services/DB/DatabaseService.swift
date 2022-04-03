import Foundation
import SQLite


/// Доступ к локальной БД
protocol IDatabaseService {
    var onChanged: Event<Void> { get }

    func start()

    func insertEvent(_ event: DBEvent)
    func selectEvents(from: Date) -> [DBEvent]

    func setUserProperty(_ property: DBUserProperty)
    func getUserProperty(for key: String) -> DBUserProperty?
    func getUserProperties() -> [DBUserProperty]
    func removeUserProperty(for key: String)

    func setSessionProperty(_ property: DBSessionProperty)
    func getSessionProperty(for key: String) -> DBSessionProperty?
    func getSessionProperties() -> [DBSessionProperty]
    func removeSessionProperty(for key: String)

    func execute(sql: String) -> [Int64]

    func reset()
}

// MARK: - DatabaseService

class DatabaseService: IDatabaseService {

    let onChanged: Event<Void> = Event()

    private lazy var db: Connection = {
        do {
            let url = FileManager.libraryPath(forFileName: "db-v1.sqlite3")!
            let connection = try Connection(url.path)
            Log.info("Open DB by path '\(url.path)'")
            return connection
        } catch let error {
            Log.error(error)
            fatalError(error.localizedDescription)
        }
    }()

    private lazy var events = EventsTable()
    private lazy var sessionProperties = SessionPropertiesTable()
    private lazy var userProperties = UserPropertiesTable()

    func start() {
        do {
            try events.create(db: db)
            try sessionProperties.create(db: db)
            try userProperties.create(db: db)
        } catch let error {
            Log.error(error)
        }
    }

    func reset() {
        do {
            try events.reset(db: db)
            try sessionProperties.reset(db: db)
            try userProperties.reset(db: db)
        } catch let error {
            Log.error(error)
        }
    }

    func setUserProperty(_ property: DBUserProperty) {
        do {
            try userProperties.insertOrReplace(property: property, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    func getUserProperty(for key: String) -> DBUserProperty? {
        do {
            return try userProperties.select(for: key, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return nil
        }
    }

    func getUserProperties() -> [DBUserProperty] {
        do {
            return try userProperties.selectAll(db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
    }

    func removeUserProperty(for key: String) {
        do {
            try userProperties.delete(for: key, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    func setSessionProperty(_ property: DBSessionProperty) {
        do {
            try sessionProperties.insertOrReplace(property: property, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    func getSessionProperty(for key: String) -> DBSessionProperty? {
        do {
            return try sessionProperties.select(for: key, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return nil
        }
    }

    func getSessionProperties() -> [DBSessionProperty] {
        do {
            return try sessionProperties.selectAll(db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
    }

    func removeSessionProperty(for key: String) {
        do {
            try sessionProperties.delete(for: key, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    func insertEvent(_ event: DBEvent) {
        do {
            try events.insert(event: event, db: db)
            self.onChanged.raise(())
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    func selectEvents(from: Date) -> [DBEvent] {
        do {
            return try events.selectEvents(from: from, db: db)
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
    }

    func execute(sql: String) -> [Int64] {
        do {
            let stmt = try self.db.prepare(sql)
            return stmt.flatMap { $0 }.compactMap { $0 as? Int64 }
        } catch let error {
            Log.error(error)
            assertionFailure(String(describing: error))
            return []
        }
    }
}

// MARK: - Events

extension IDatabaseService {

    func insert(eventType: DBEventType) {
        let event = DBEvent(eventType: eventType)
        self.insertEvent(event)
    }
}

// MARK: - UserProperties

extension IDatabaseService {

    func setUserProperty(value: Double, for key: String) {
        let property = DBUserProperty(key: key, value: nil, numericValue: value)
        self.setUserProperty(property)
    }

    func setUserProperty(value: String, for key: String) {
        let property = DBUserProperty(key: key, value: value, numericValue: nil)
        self.setUserProperty(property)
    }

    func setUserProperty(value: Bool, for key: String) {
        let property = DBUserProperty(key: key, value: nil, numericValue: value ? 1 : 0)
        self.setUserProperty(property)
    }
}

// MARK: - SessionProperties

extension IDatabaseService {

    func setSessionProperty(value: Double, for key: String) {
        let property = DBSessionProperty(key: key, value: nil, numericValue: value)
        self.setSessionProperty(property)
    }

    func setSessionProperty(value: String, for key: String) {
        let property = DBSessionProperty(key: key, value: value, numericValue: nil)
        self.setSessionProperty(property)
    }

    func setSessionProperty(value: Bool, for key: String) {
        let property = DBSessionProperty(key: key, value: nil, numericValue: value ? 1 : 0)
        self.setSessionProperty(property)
    }
}
