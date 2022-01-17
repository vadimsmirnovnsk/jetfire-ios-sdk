import Foundation

/// Активная задача планировщика
/// Если наступило время активации, то активирует себя посредством активатора :)
final class SchedulerLiveTask {

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
        if self.task.isExpired {
            self.completion()
        } else if self.task.canBeActivated {
            self.taskActivator.activate()
            self.completion()
        }
    }
}
