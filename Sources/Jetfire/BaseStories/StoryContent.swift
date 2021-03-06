import Foundation

public class StoryContent {

	let story: IStory
	let snaps: [ISnap]

	init(story: IStory, snaps: [ISnap]) {
		self.story = story
		self.snaps = snaps
	}
}

public protocol IStory {

	/// Уникальный айдишник для идентификации — JetFireFeatureStory.id
	var id: String { get }
	/// Уникальный айдишник для идентификации — JetFireCampaign.id
	var campaignId: Int64 { get }
	/// Подстрочник под стори в коллекшен вьюхе
	var title: String { get }
	/// Сколько секунд продолжается каждый снап в стори
	var duration: TimeInterval { get }
	/// Для сортировки — больше выше
	var priority: Int { get }
	/// Сколько стори живет после прочтения в днях
	var lifetime: TimeInterval { get }
	/// True — Показывать только на тесте
	var isTest: Bool? { get }
	/// True — всегда перематывать на 0 на старте
	var alwaysRewind: Bool? { get }
//	/// Число версии без точек, с которой начинает показываться сториз (например, 1.5.4 -> 154)
//	var startVersion: Int? { get }

}

extension IStory {

	var readId: String { "\(self.campaignId.string)_\(self.id)" }

}

public protocol ISnap {

	var id: String { get }

}
