import Foundation

class LoggerContainer {
    static var logger: ILoggerService?
}

// MARK: - Log

class Log {

    static func info(_ message: @autoclosure () -> String) {
        LoggerContainer.logger?.info(message())
    }

    static func error(_ message: @autoclosure () -> String) {
        LoggerContainer.logger?.error(message())
    }

    static func error(_ error: @autoclosure () -> Error) {
        LoggerContainer.logger?.error(error())
    }
}
