import Foundation

protocol ILoggerService {
    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

// MARK: - LoggerService

class LoggerService: ILoggerService {

    func info(_ message: @autoclosure () -> String) {
        print("[Jetfire] \(message())")
    }

    func error(_ message: @autoclosure () -> String) {
        print("[Jetfire] \(message())")
    }
}

// MARK: - Extensions

extension ILoggerService {

    func error(_ error: @autoclosure () -> Error) {
        self.error(String(describing: error()))
    }

}
