import Foundation

enum SchedulerTaskType {
    case story
    case push
}

/// Задание планировщика, пригодное для сериализации
/// Нужно только для того чтобы сохранить на диск, восстановить и сделать из него `SchedulerLiveTask`
struct SchedulerStorableTask {
    let type: SchedulerTaskType
    let campaignId: Int64
    let storyId: Int64?
    let activationDate: Date?
    let expirationDate: Date?
}

// MARK: - Hashable

extension SchedulerStorableTask: Hashable {

    static func == (lhs: SchedulerStorableTask, rhs: SchedulerStorableTask) -> Bool {
        lhs.type == rhs.type && lhs.campaignId == rhs.campaignId && lhs.storyId == rhs.storyId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.type)
        hasher.combine(self.campaignId)
        hasher.combine(self.storyId)
    }
}

// MARK: - Extensions

extension SchedulerStorableTask {

    var canBeActivated: Bool {
        if let activationDate = self.activationDate {
            let now = Date()
            if now >= activationDate && !self.isExpired {
                return true
            }
        } else {
            return true
        }
        return false
    }

    var isExpired: Bool {
        if let expirationDate = self.expirationDate {
            return Date.now > expirationDate
        } else {
            return false
        }
    }
}
