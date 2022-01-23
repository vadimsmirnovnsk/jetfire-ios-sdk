import Foundation

/// Обертка свойства, которая использует `UserDefaults.standard` для хранения `wrappedValue`
@propertyWrapper public class UserDefault<Value: Codable>: IUserDefault {
    let key: String
    let defaultValue: Value
    var runtimeValue: Value?
    let storage: UserDefaults = .standard

    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: Value {
        get {
            getValue()
        }
        set {
            setValue(value: newValue)
        }
    }
}

// MARK: - Reset

extension UserDefault {

    func reset() {
        self.setValue(value: self.defaultValue)
    }
}
