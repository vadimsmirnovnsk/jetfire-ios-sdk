import Foundation

public protocol IJetfireLogTracker {
    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

// MARK: - Console

class ConsoleLogTracker: IJetfireLogTracker {

    func info(_ message: @autoclosure () -> String) {
        print(message())
    }

    func error(_ message: @autoclosure () -> String) {
        print(message())
    }
}
