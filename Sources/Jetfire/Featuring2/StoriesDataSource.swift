
import OrderedCollections
import UIKit

/// Источник данных для карусели сторис
protocol IMutableStoriesDataSource {
    func append(storyId: Int64, campaignId: Int64)
    func remove(storyId: Int64, campaignId: Int64)
}

// MARK: - StoryKey

private struct StoryKey: Hashable {
    let storyId: Int64
    let campaignId: Int64
}

// MARK: - StoriesDataSource

final class StoriesDataSource: IStoriesDataSource, IMutableStoriesDataSource {

    private let storiesCampaignsProvider: IStoriesCampaignsProvider
    private let factory: StoriesFactory
    private var storiesDictionary: OrderedDictionary<StoryKey, BaseStory> = [:]
    private var isDirty: Bool = false

    var stories: [BaseStory] {
        Array(storiesDictionary.values)
    }

    let onChanged: Event<Void> = Event()

    init(
        storiesCampaignsProvider: IStoriesCampaignsProvider,
        factory: StoriesFactory
    ) {
        self.storiesCampaignsProvider = storiesCampaignsProvider
        self.factory = factory
    }

    func append(storyId: Int64, campaignId: Int64) {
        let key = StoryKey(storyId: storyId, campaignId: campaignId)
        guard !self.storiesDictionary.keys.contains(key) else { return }
        let campaigns = self.storiesCampaignsProvider.campaigns
        let campaign = campaigns.first { $0.id == campaignId }
        let story = campaign?.stories.first { $0.id == storyId }
        // Если на момент активации историю не нашли в данных,
        // значит состояние приложения поменялось, и эта история
        // уже не актуальна, игнорируем ее
        guard let campaign = campaign, let story = story else { return }
        Log.info("Activate story \(campaign.debugDescription)")
        let baseStory = self.factory.makeStory(story: story, campaignId: campaignId)
        self.storiesDictionary[key] = baseStory
        self.isDirty = true
        // Чтобы стрельнуть сигналом один раз даже если добавили много сторис подряд
        DispatchQueue.main.async {
            guard self.isDirty else { return }
            self.isDirty = false
            self.onChanged.raise(())
        }
    }

    func remove(storyId: Int64, campaignId: Int64) {
        let key = StoryKey(storyId: storyId, campaignId: campaignId)
        guard self.storiesDictionary.keys.contains(key) else { return }
        self.storiesDictionary[key] = nil
        self.isDirty = true
        // Чтобы стрельнуть сигналом один раз даже если удалили много сторис подряд
        DispatchQueue.main.async {
            guard self.isDirty else { return }
            self.isDirty = false
            self.onChanged.raise(())
        }
    }
}
