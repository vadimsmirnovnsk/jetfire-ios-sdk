import Foundation
import SQLite

//    CREATE TABLE "session_properties"
//    (
//        "key"           VARCHAR(255)   NOT NULL,
//        "value"         VARCHAR(255)   NULL,
//        "numeric_value" INTEGER        NULL
//    )

// MARK: - SessionPropertiesTable

class SessionPropertiesTable {

    private let key = Expression<String>(DBSessionProperty.CodingKeys.key.rawValue)
    private let value = Expression<String?>(DBSessionProperty.CodingKeys.value.rawValue)
    private let numericValue = Expression<Double?>(DBSessionProperty.CodingKeys.numericValue.rawValue)
    private let sessionProperties = Table("session_properties")

    func create(db: Connection) throws {
        try db.run(sessionProperties.drop(ifExists: true))
        try db.run(sessionProperties.create(ifNotExists: true) { t in
            t.column(key, primaryKey: true)
            t.column(value)
            t.column(numericValue)
        })
    }

    func insertOrReplace(property: DBSessionProperty, db: Connection) throws {
        Log.info("Will insert \(property.debugDescription)")
        try db.run(sessionProperties.insert(or: .replace, encodable: property))
    }

    func select(for queryKey: String, db: Connection) throws -> DBSessionProperty? {
        let query = self.sessionProperties.select(*).where(key == queryKey)
        let properties = try db.prepare(query)
        let result: [DBSessionProperty] = try properties.map { row in
            try row.decode()
        }
        return result.first
    }

    func delete(for queryKey: String, db: Connection) throws {
        let row = self.sessionProperties.filter(key == queryKey)
        try db.run(row.delete())
    }

    func selectAll(db: Connection) throws -> [DBSessionProperty] {
        let query = self.sessionProperties.select(*)
        let properties = try db.prepare(query)
        let result: [DBSessionProperty] = try properties.map { row in
            try row.decode()
        }
        return result
    }
}

// MARK: - DBSessionProperty

struct DBSessionProperty: Codable {

    let key: String
    let value: String?
    let numericValue: Double?

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case value = "value"
        case numericValue = "numeric_value"
    }
}

// MARK: - CustomDebugStringConvertible

extension DBSessionProperty: CustomDebugStringConvertible {
    var debugDescription: String {
        let value = value ?? "nil"
        let numericValue = numericValue.map { String(describing: $0) } ?? "nil"
        return "DBSessionProperty [key=\(key), value=\(value), numericValue=\(numericValue)]"
    }
}
