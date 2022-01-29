import VNEssential

/// Источник данных для карусели сторис
protocol IMutableStoriesDataSource {
    func start()
    func append(story: JetFireFeatureStory, campaignId: Int64)
}

// MARK: - StorableStory

struct StorableStory: Hashable, Codable {
    let campaignId: Int64
    let storyId: Int64
}

// MARK: - StoriesDataSource

final class StoriesDataSource: IStoriesDataSource, IMutableStoriesDataSource {

    private let availableCampaignsProvider: IAvailableCampaignsProvider
    private let userSettings: IUserSettings
    private let factory: StoriesFactory
    private var started: Bool = false

    private var storableStories: [StorableStory] {
        get { self.userSettings.storableStories }
        set { self.userSettings.storableStories = newValue }
    }

    private var cache: [StorableStory: JetFireFeatureStory] = [:]

    var stories: [BaseStory] = []
    let onChanged: Event<Void> = Event()

    init(
        availableCampaignsProvider: IAvailableCampaignsProvider,
        userSettings: IUserSettings,
        factory: StoriesFactory
    ) {
        self.availableCampaignsProvider = availableCampaignsProvider
        self.userSettings = userSettings
        self.factory = factory
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        self.availableCampaignsProvider.onUpdate.add(self) { [weak self] in
            self?.refreshStories()
        }
    }

    func append(story: JetFireFeatureStory, campaignId: Int64) {
        let baseStory = self.factory.makeStory(story: story, campaignId: campaignId)
        if self.stories.contains(baseStory) {
            Log.info("Story id:\(story.id) campaignId:\(campaignId) already in stories data source")
        } else {
            Log.info("Story id:\(story.id) campaignId:\(campaignId) inserted into stories data source")
            self.storableStories.append(
                StorableStory(campaignId: campaignId, storyId: story.id)
            )
            self.stories.append(baseStory)
            self.onChanged.raise(())
        }
    }
}

// MARK: - Private

extension StoriesDataSource {

    private func refreshStories() {
        guard !self.availableCampaignsProvider.isDirty else { return }
        self.cache = self.makeCache()

        var newStories: [BaseStory] = []
        var newStorableStories: [StorableStory] = []
        for key in self.storableStories {
            if let story = self.cache[key], !newStorableStories.contains(key) {
                newStorableStories.append(key)
                newStories.append(self.factory.makeStory(story: story, campaignId: key.campaignId))
            }
        }
        if self.stories != newStories {
            self.storableStories = newStorableStories
            self.stories = newStories
            self.onChanged.raise(())
        }
    }

    private func makeCache() -> [StorableStory: JetFireFeatureStory] {
        self.availableCampaignsProvider.campaigns.reduce(into: [:]) { result, campain in
            for story in campain.stories {
                let key = StorableStory(campaignId: campain.id, storyId: story.id)
                result[key] = story
            }
        }
    }
}
