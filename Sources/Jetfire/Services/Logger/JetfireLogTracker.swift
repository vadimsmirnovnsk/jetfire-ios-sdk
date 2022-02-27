import Foundation

public protocol IJetfireLogTracker {
    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}
