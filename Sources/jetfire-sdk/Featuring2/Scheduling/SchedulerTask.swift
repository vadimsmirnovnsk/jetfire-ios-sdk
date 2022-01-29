import Foundation

/// Активная задача планировщика
/// Если наступило время активации, то активирует себя посредством активатора :)
final class SchedulerTask {

    let task: SchedulerStorableTask
    private let taskActivator: ISchedulerTaskActivator
    private let completion: () -> Void

    init(
        task: SchedulerStorableTask,
        taskActivator: ISchedulerTaskActivator,
        completion: @escaping () -> Void
    ) {
        self.task = task
        self.taskActivator = taskActivator
        self.completion = completion
    }

    func tick() {
        guard !self.task.isExpired && self.task.canBeActivated else { return }
        self.taskActivator.activate()
        self.completion()
    }
}
