import VNEssential
import UIKit
import UIColorHexSwift
import VNBase

/// Делает BaseStory из JetFireFeatureStory
final class StoriesFactory {

    private let processTargetService: ProcessTargetService
    private let router: BaseRouter
    private let storiesAnalytics: IStoriesAnalytics
    unowned var storyService: IStoryService!

    init(
        storiesAnalytics: IStoriesAnalytics,
        processTargetService: ProcessTargetService,
        router: BaseRouter
    ) {
        self.storiesAnalytics = storiesAnalytics
        self.processTargetService = processTargetService
        self.router = router
    }
    
    func makeStory(story: JetFireFeatureStory, campaignId: Int64) -> BaseStory {
        let infoStory = InfoStoryModel(
            id: story.id.string,
            campaignId: campaignId,
            type: .firebaseInfo,
            title: story.cover.title,
            duration: 15,
            priority: story.priority.int,
            image: story.cover.image.url,
            bgColorString: nil,
            afterReadTime: story.settings.afterReadExpire.timeInterval,
            isTest: nil,
            alwaysRewind: story.settings.alwaysRewind
        )
        let infoSnaps = story.frames.enumerated().map { index, fr in
            return InfoSnap(
                id: fr.id.string,
                storyId: story.id.string,
                campaignId: campaignId,
                index: index,
                type: .info,
                title: fr.title,
                subtitle: fr.subtitle,
                message: fr.message,
                bgColorString: fr.background.color,
                bgImageString: fr.image.url,
                textColorString: fr.font.color,
                button: nil
            )
        }
        let storyContent = StoryContent(story: infoStory, snaps: infoSnaps)
        let cellVM = StoryInfoCellVM(infoStory: infoStory)
        let snapVMs = infoSnaps.map { InfoSnapVM(snap: $0, processTargetService: self.processTargetService, router: self.router, analytics: self.storiesAnalytics) }
        let baseStory = BaseStory(service: self.storyService, analytics: self.storiesAnalytics, content: storyContent, previewVM: cellVM, snaps: snapVMs)
        return baseStory
    }
}