import Foundation
import SQLite

//    CREATE TABLE "user_properties"
//    (
//        "key"             VARCHAR(255) NOT NULL,
//        "value"           TEXT         NULL,
//        "numeric_value"   INTEGER      NULL
//    )

// MARK: - UserPropertiesTable

class UserPropertiesTable {

    private let key = Expression<String>(DBSessionProperty.CodingKeys.key.rawValue)
    private let value = Expression<String?>(DBSessionProperty.CodingKeys.value.rawValue)
    private let numericValue = Expression<Double?>(DBSessionProperty.CodingKeys.numericValue.rawValue)
    private let userProperties = Table("user_properties")

    func create(db: Connection) throws {
        try db.run(userProperties.create(ifNotExists: true) { t in
            t.column(key, primaryKey: true)
            t.column(value)
            t.column(numericValue)
        })
    }

    func insertOrReplace(property: DBUserProperty, db: Connection) throws {
        Log.info("Will insert \(property.debugDescription)")
        try db.run(userProperties.insert(or: .replace, encodable: property))
    }

    func select(for queryKey: String, db: Connection) throws -> DBUserProperty? {
        let query = self.userProperties.select(*).where(key == queryKey)
        let properties = try db.prepare(query)
        let result: [DBUserProperty] = try properties.map { row in
            try row.decode()
        }
        return result.first
    }

    func delete(for queryKey: String, db: Connection) throws {
        let row = self.userProperties.filter(key == queryKey)
        try db.run(row.delete())
    }

    func selectAll(db: Connection) throws -> [DBUserProperty] {
        let query = self.userProperties.select(*)
        let properties = try db.prepare(query)
        let result: [DBUserProperty] = try properties.map { row in
            try row.decode()
        }
        return result
    }
}

// MARK: - DBUserProperty

struct DBUserProperty: Codable {

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

extension DBUserProperty: CustomDebugStringConvertible {
    var debugDescription: String {
        let value = value ?? "nil"
        let numericValue = numericValue.map { String(describing: $0) } ?? "nil"
        return "DBUserProperty [key=\(key), value=\(value), numericValue=\(numericValue)]"
    }
}
