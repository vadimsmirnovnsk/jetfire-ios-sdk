import Foundation

/// Протокол, описывающий свойство, которое живет в UserDefaults
protocol IUserDefault: AnyObject {
    associatedtype Value: Codable

    var storage: UserDefaults { get }
    var key: String { get }
    var defaultValue: Value { get }
    var runtimeValue: Value? { get set }
}

// MARK: - Get, Set

extension IUserDefault {

    func getValue() -> Value {
        if let value = runtimeValue {
            return value
        }
        if let data = storage.object(forKey: key) as? Data {
            do {
                let value = try JSONDecoder().decode(Value.self, from: data)
                runtimeValue = value
                return value
            } catch let error {
                runtimeValue = defaultValue
                assertionFailure(String(describing: error))
                return defaultValue
            }
        }
        return defaultValue
    }

    func setValue(value: Value) {
        do {
            let data = try JSONEncoder().encode(value)
            storage.set(data, forKey: key)
            runtimeValue = value
            #if DEBUG
            storage.synchronize()
            #endif
        } catch let error {
            runtimeValue = nil
            assertionFailure(String(describing: error))
        }
    }
}
