import Foundation

protocol ILoggerService {

    func appendTracker(_ tracker: IJetfireLogTracker)

    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

// MARK: - LoggerService

class LoggerService: ILoggerService {

    private let queue = DispatchQueue(label: "JetfireLoggerServiceQueue")
    private var trackers: [IJetfireLogTracker] = []

    func appendTracker(_ tracker: IJetfireLogTracker) {
        queue.async {
            self.trackers.append(tracker)
        }
    }

    func info(_ message: @autoclosure () -> String) {
        queue.sync {
            self.trackers.forEach {
                $0.info(message())
            }
        }
    }

    func error(_ message: @autoclosure () -> String) {
        queue.sync {
            self.trackers.forEach {
                $0.error(message())
            }
        }
    }
}

// MARK: - Extensions

extension ILoggerService {

    func error(_ error: @autoclosure () -> Error) {
        self.error(String(describing: error()))
    }
}
