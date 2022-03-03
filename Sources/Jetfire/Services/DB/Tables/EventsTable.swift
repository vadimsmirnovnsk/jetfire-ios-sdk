import Foundation
import SQLite

//    CREATE TABLE "events"
//    (
//        "id"           INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
//        "event_type"   INTEGER                           NOT NULL,
//        "custom_event" VARCHAR(255)                      NULL,
//        "event_uuid"   VARCHAR(20)                       NOT NULL,
//        "campaign_id"  INTEGER                           NULL,
//        "feature"      VARCHAR(255)                      NULL,
//        "feature_id"   INTEGER                           NULL,
//        "entity_id"    INTEGER                           NULL,
//        "date"         DATE                              DEFAULT CURRENT_TIMESTAMP NOT NULL,
//        "timestamp"    DATETIME                          DEFAULT CURRENT_TIMESTAMP NOT NULL,
//        "data"         TEXT                              NULL
//    );

// MARK: - EventsTable

class EventsTable {

    private let id = Expression<Int64>(DBEvent.CodingKeys.id.rawValue)
    private let eventType = Expression<Int64>(DBEvent.CodingKeys.rawEventType.rawValue)
    private let customEvent = Expression<String?>(DBEvent.CodingKeys.customEvent.rawValue)
    private let eventUuid = Expression<String>(DBEvent.CodingKeys.eventUuid.rawValue)
    private let campaignId = Expression<Int64?>(DBEvent.CodingKeys.campaignId.rawValue)
    private let feature = Expression<String?>(DBEvent.CodingKeys.feature.rawValue)
    private let entityId = Expression<String?>(DBEvent.CodingKeys.entityId.rawValue)
    private let date = Expression<String>(DBEvent.CodingKeys.date.rawValue)
    private let timestamp = Expression<Date>(DBEvent.CodingKeys.timestamp.rawValue)
    private let data = Expression<Data?>(DBEvent.CodingKeys.data.rawValue)
    private let events = Table("events")

    func create(db: Connection) throws {
        try db.run(events.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(eventType)
            t.column(customEvent)
            t.column(eventUuid)
            t.column(campaignId)
            t.column(feature)
            t.column(entityId)
            t.column(date)
            t.column(timestamp)
            t.column(data)
        })
    }

    func reset(db: Connection) throws {
        try db.run(events.drop(ifExists: true))
        try create(db: db)
    }

    func insert(event: DBEvent, db: Connection) throws {
        Log.info("Will insert \(event.debugDescription)")
        try db.run(events.insert(event))
    }

    func selectEvents(from: Date, db: Connection) throws -> [DBEvent] {
        let query = self.events.select(*).where(timestamp >= from)
        let events = try db.prepare(query)
        let result: [DBEvent] = try events.map { row in
            try row.decode()
        }
        return result
    }
}

// MARK: - DBEvent

struct DBEvent: Codable {

    /// ID события
    let id: Int?
    /// Интовый id события из протобафовского EventType
    let rawEventType: Int
    /// Если тип события кастомный, то тут имя этого кастомного события
    let customEvent: String?
    /// Рандомно сгенерированный UUID
    let eventUuid: String
    /// Данные из фичеринга, если есть
    let campaignId: Int64?
    /// Текстовое имя фичи
    let feature: String?
    /// Данные из фичеринга, если есть. Например, id истории
    let entityId: String?
    /// Отдельно поле с датой без времени для удобства
    let date: String
    /// Полный таймстемп события (миллисекунды)
    let timestamp: Date
    /// Текстовое поле, чтобы хранить например, json с дополнительными параметрами
    let data: Data?

    var eventType: DBEventType {
        DBEventType(rawValue: rawEventType) ?? .custom
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case rawEventType = "event_type"
        case customEvent = "custom_event"
        case eventUuid = "event_uuid"
        case campaignId = "campaign_id"
        case feature = "feature"
        case entityId = "entity_id"
        case date = "date"
        case timestamp = "timestamp"
        case data = "data"
    }

    private init(
        id: Int?,
        eventType: DBEventType,
        customEvent: String?,
        eventUuid: String,
        campaignId: Int64?,
        feature: String?,
        entityId: String?,
        date: String,
        timestamp: Date,
        data: Data?
    ) {
        self.id = id
        self.rawEventType = eventType.rawValue
        self.customEvent = customEvent
        self.eventUuid = eventUuid
        self.campaignId = campaignId
        self.feature = feature
        self.entityId = entityId
        self.date = date
        self.timestamp = timestamp
        self.data = data
    }

    init(
        eventType: DBEventType,
        campaignId: Int64? = nil,
        feature: String? = nil,
        entityId: String? = nil,
        customEvent: String? = nil,
        data: Data? = nil
    ) {
        let date = Date()
        self.init(
            id: nil,
            eventType: eventType,
            customEvent: customEvent,
            eventUuid: UUID().uuidString,
            campaignId: campaignId,
            feature: feature,
            entityId: entityId,
            date:  DateFormatter.db_yyyy_mm_dd.string(from: date),
            timestamp: date,
            data: data
        )
    }
}

// MARK: - DBEventType

enum DBEventType: Int, Codable {
    case custom = 0
    case firstLaunch = 1
    case applicationStart = 2
    case applicationShutdown = 3
    case featureOpen = 4
    case featureClose = 5
    case featureUse = 6
    case storyOpen = 7
    case storyTap = 8
    case storyClose = 9
    case pushShow = 10
    case pushTap = 11
    case pushClose = 12
    case toasterShow = 13
    case toasterTap = 14
    case toasterClose = 15
    case featureAccepted = 16
    case jetfireStart = 17
    case jetfireFeaturingStart = 18
}

// MARK: - DBEventType Log

private extension DBEventType {
    var stringValue: String {
        switch self {
        case .custom:
            return "custom"
        case .firstLaunch:
            return "first_launch"
        case .applicationStart:
            return "application_start"
        case .applicationShutdown:
            return "application_shutdown"
        case .featureOpen:
            return "feature_open"
        case .featureClose:
            return "feature_close"
        case .featureUse:
            return "feature_use"
        case .storyOpen:
            return "story_open"
        case .storyTap:
            return "story_tap"
        case .storyClose:
            return "story_close"
        case .pushShow:
            return "push_show"
        case .pushTap:
            return "push_tap"
        case .pushClose:
            return "push_close"
        case .toasterShow:
            return "toaster_show"
        case .toasterTap:
            return "toaster_tap"
        case .toasterClose:
            return "toaster_close"
        case .featureAccepted:
            return "feature_accepted"
        case .jetfireStart:
            return "jetfire_start"
        case .jetfireFeaturingStart:
            return "jetfire_featuring_start"
        }
    }
}

// MARK: - DBEvent

extension DBEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        let params: [String: Any?] = [
            "campaignId": campaignId,
            "feature": feature,
            "entityId": entityId,
            "customEvent": customEvent
        ]
        let description = params
            .reduce(into: [:]) { result, item in result[item.key] = item.value }
            .map { "\($0.key):\($0.value)" }
            .joined(separator: ", ")
        return "DBEvent '\(eventType.stringValue)' [\(description)]"
    }
}
