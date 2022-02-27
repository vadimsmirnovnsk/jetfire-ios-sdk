import Foundation
import Jetfire

class ConsoleLogTracker: IJetfireLogTracker {

    func info(_ message: @autoclosure () -> String) {
        print(message())
    }

    func error(_ message: @autoclosure () -> String) {
        print(message())
    }
}

