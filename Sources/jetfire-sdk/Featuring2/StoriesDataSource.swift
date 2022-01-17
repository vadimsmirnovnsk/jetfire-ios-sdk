import VNEssential

/// Источник данных для карусели сторис
protocol IMutableStoriesDataSource {
    func append(story: JetFireFeatureStory, campaignId: Int64)
}

// MARK: - StoriesDataSource

final class StoriesDataSource: IStoriesDataSource, IMutableStoriesDataSource {

    private let factory: StoriesFactory

    #warning("Нужна сериализация")
    var stories: [BaseStory] = []
    let onChanged: Event<Void> = Event()

    init(factory: StoriesFactory) {
        self.factory = factory
    }

    func append(story: JetFireFeatureStory, campaignId: Int64) {
        let story = self.factory.makeStory(story: story, campaignId: campaignId)
        if !self.stories.contains(story) {
            self.stories.append(story)
            self.onChanged.raise(())
        }
    }
}
