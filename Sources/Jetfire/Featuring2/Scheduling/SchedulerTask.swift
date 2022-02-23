import Foundation

/// Активная задача планировщика
/// Если наступило время активации, то активирует себя посредством активатора :)
final class SchedulerTask {

    private let task: SchedulerStorableTask
    private let taskActivator: ISchedulerTaskActivator

    init(
        task: SchedulerStorableTask,
        taskActivator: ISchedulerTaskActivator
    ) {
        self.task = task
        self.taskActivator = taskActivator
    }

    func tick() {
        if self.task.isExpired {
            self.taskActivator.deactivate()
        } else if self.task.canBeActivated {
            self.taskActivator.activate()
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension SchedulerTask: CustomDebugStringConvertible {

    var debugDescription: String {
        "Task '\(self.task.type.stringValue)' [\(self.info)]"
    }

    private var info: String {
        var result: [String] = []
        result.append("campain: \(self.task.campaignId)")
        if let activationDate = self.task.activationDate {
            result.append("activation: \(DateFormatter.dateTime.string(from: activationDate))")
        }
        if let expirationDate = self.task.expirationDate {
            result.append("expiration: \(DateFormatter.dateTime.string(from: expirationDate))")
        }
        if self.task.isExpired {
            result.append("isExpired")
        } else if self.task.canBeActivated {
            result.append("canBeActivated")
        }
        return result.joined(separator: ", ")
    }
}

// MARK: - Array<SchedulerTask>

extension Array where Element == SchedulerTask {
    var debugDescription: String {
        self.isEmpty ? "[]" : self.map { $0.debugDescription }.joined(separator: ", ")
    }
}

// MARK: - SchedulerTaskType

private extension SchedulerTaskType {
    var stringValue: String {
        switch self {
        case .story:
            return "story"
        case .toaster:
            return "toaster"
        }
    }
}
