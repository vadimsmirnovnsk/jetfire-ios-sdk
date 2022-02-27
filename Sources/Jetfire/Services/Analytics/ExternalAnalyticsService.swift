import Foundation

/// Интерфейс для аналитики снаружи SDK
protocol IExternalAnalyticsService {

    func logEvent(_ name: String)

    func setUserProperty(_ value: Any, forName: String)
    func removeUserProperty(forName: String)

    func setSessionProperty(_ value: Any, forName: String)
    func removeSessionProperty(forName: String)
}

// MARK: - ExternalAnalyticsService

class ExternalAnalyticsService: IExternalAnalyticsService {

    private let databaseService: IDatabaseService

    init(databaseService: IDatabaseService) {
        self.databaseService = databaseService
    }

    func logEvent(_ name: String) {
        let event = DBEvent(eventType: .custom, customEvent: name)
        self.databaseService.insertEvent(event)
    }

    func setUserProperty(_ value: Any, forName name: String) {
        if let stringValue = value as? String {
            self.databaseService.setUserProperty(value: stringValue, for: name)
        } else if let boolValue = value as? Bool {
            self.databaseService.setUserProperty(value: boolValue, for: name)
        } else if let doubleValue = Double(String(describing: value)) {
            self.databaseService.setUserProperty(value: doubleValue, for: name)
        } else if let optionalValue = value as? OptionalProtocol, !optionalValue.hasValue {
            self.databaseService.removeUserProperty(for: name)
        } else {
            Log.error("Unable to set user property \(value) for key \(name)")
        }
    }

    func removeUserProperty(forName name: String) {
        self.databaseService.removeUserProperty(for: name)
    }

    func setSessionProperty(_ value: Any, forName name: String) {
        if let stringValue = value as? String {
            self.databaseService.setSessionProperty(value: stringValue, for: name)
        } else if let boolValue = value as? Bool {
            self.databaseService.setSessionProperty(value: boolValue, for: name)
        } else if let doubleValue = Double(String(describing: value)) {
            self.databaseService.setSessionProperty(value: doubleValue, for: name)
        } else if let optionalValue = value as? OptionalProtocol, !optionalValue.hasValue {
            self.databaseService.removeSessionProperty(for: name)
        } else {
            Log.error("Unable to set user property \(value) for key \(name)")
        }
    }

    func removeSessionProperty(forName name: String) {
        self.databaseService.removeSessionProperty(for: name)
    }
}

// MARK: - OptionalProtocol

private protocol OptionalProtocol {
    var hasValue: Bool { get }
}

extension Optional: OptionalProtocol {
    var hasValue: Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }
}
