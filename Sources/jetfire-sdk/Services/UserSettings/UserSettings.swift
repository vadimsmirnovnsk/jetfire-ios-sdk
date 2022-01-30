import Foundation

/// Хранимые настройки пользователя
protocol IUserSettings: AnyObject {

    var didStartEarly: Bool { get set }
    var readStories: [String: Date] { get set }
    var showCampaign: [String: Date] { get set }
    var lastApplicationStartShowDate: Date? { get set }
    var lastPushShowDate: Date? { get set }
    var shownToasters: [Int64: Date] { get set }
    var lastToasterShowDate: Date? { get set }
    var userId: String { get set }
    var pendingNotificationIds: [String] { get set }
    var lastFlushDate: Date? { get set }
    var schedulerStorableTasks: [SchedulerStorableTask] { get set }
    var storableStories: [StorableStory] { get set }

    func reset()
}

// MARK: - UserSettings

class UserSettings: IUserSettings {

    @UserDefault(key: "jetfire_didStartEarly", defaultValue: false)
    var didStartEarly: Bool

    @UserDefault(key: "jetfire_readStories", defaultValue: [:])
    var readStories: [String: Date]

    @UserDefault(key: "jetfire_showCampaign", defaultValue: [:])
    var showCampaign: [String: Date]

    @UserDefault(key: "jetfire_lastApplicationStartShowDate", defaultValue: nil)
    var lastApplicationStartShowDate: Date?

    @UserDefault(key: "jetfire_lastPushShowDate", defaultValue: nil)
    var lastPushShowDate: Date?

    @UserDefault(key: "jetfire_shownToasters", defaultValue: [:])
    var shownToasters: [Int64: Date]

    @UserDefault(key: "jetfire_lastToasterShowDate", defaultValue: nil)
    var lastToasterShowDate: Date?

    @UserDefault(key: "jetfire_userId", defaultValue: "")
    var userId: String

    @UserDefault(key: "jetfire_pendingNotificationIds", defaultValue: [])
    var pendingNotificationIds: [String]

    @UserDefault(key: "jetfire_lastFlushDate", defaultValue: nil)
    var lastFlushDate: Date?

    @UserDefault(key: "jetfire_schedulerStorableTasks", defaultValue: [])
    var schedulerStorableTasks: [SchedulerStorableTask]

    @UserDefault(key: "jetfire_storableStories", defaultValue: [])
    var storableStories: [StorableStory]
}

// MARK: - Reset

extension UserSettings {

    func reset() {
        _didStartEarly.reset()
        _readStories.reset()
        _showCampaign.reset()
        _lastApplicationStartShowDate.reset()
        _lastPushShowDate.reset()
        _shownToasters.reset()
        _lastToasterShowDate.reset()
        _userId.reset()
        _pendingNotificationIds.reset()
        _lastFlushDate.reset()
    }
}
