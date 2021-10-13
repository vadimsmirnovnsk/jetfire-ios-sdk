//import Firebase
import VNBase

typealias StoriesBlock = ([BaseStory]) -> Void

final class StoriesStorage {

	private(set) var stories: [BaseStory] = []
	
//	private let ref = Database.database().reference()
	unowned var service: IStoryService!

	private let processTargetService: ProcessTargetService
	private let router: BaseRouter

	init(processTargetService: ProcessTargetService, router: BaseRouter) {
		self.processTargetService = processTargetService
		self.router = router
	}

	func fetchStories(completion: @escaping StoriesBlock) {
//		self.ref.child("stories").observeSingleEvent(of: .value) { [weak self] firebaseData in
//			let stories = self?.process(firebase: firebaseData) ?? []
//			self?.stories = stories
//			completion(stories)
//		}
		completion([])
	}

//	private func process(firebase data: DataSnapshot) -> [BaseStory] {
//		guard let array = data.value as? [[ String : Any ]] else { return [] }
//
//		let stories = array.compactMap { dict -> BaseStory? in
//			guard let storyChild = dict["story"] as? [ String : Any ],
//				let snapsChild = dict["snaps"] as? [[ String : Any ]] else { return nil }
//
//			guard let storyTuple = self.make(story: storyChild) else { return nil }
//
//			let snapsTuple = self.make(snaps: snapsChild)
//			guard !snapsTuple.snaps.isEmpty else { return nil }
//
//			let content = StoryContent(story: storyTuple.story, snaps: snapsTuple.snaps)
//			return BaseStory(service: self.service, content: content,
//							 previewVM: storyTuple.vm, snaps: snapsTuple.vms)
//		}
//
//		return stories
//	}

//	private func process(user data: DataSnapshot?) -> [BaseStory] {
//		guard let dict = data?.value as? [ String : Any ] else { return [] }
//		let array = [dict]
//
//		let stories = array.compactMap { dict -> BaseStory? in
//			guard let storyChild = dict["story"] as? [ String : Any ],
//				let snapsChild = dict["snaps"] as? [[ String : Any ]] else { return nil }
//
//			guard let storyTuple = self.make(story: storyChild) else { return nil }
//
//			let snapsTuple = self.make(snaps: snapsChild)
//			guard !snapsTuple.snaps.isEmpty else { return nil }
//
//			let content = StoryContent(story: storyTuple.story, snaps: snapsTuple.snaps)
//			return BaseStory(service: self.service, content: content,
//							 previewVM: storyTuple.vm, snaps: snapsTuple.vms)
//		}
//
//		return stories
//	}
//
//	private func make(snaps: [[ String : Any ]]) -> (snaps: [ISnap], vms: [BaseSnapVM]) {
//		var vms: [BaseSnapVM] = []
//		var iSnaps: [ISnap] = []
//		for snap in snaps {
//			guard let data = try? JSONSerialization.data(withJSONObject: snap, options: []) else { continue }
//			guard let typeString = snap["type"] as? String, let type = SnapType(rawValue: typeString) else { continue }
//
//			switch type {
//				case .info:
//					guard let object = try? JSONDecoder().decode(InfoSnap.self, from: data) else { continue }
//					vms.append(InfoSnapVM(snap: object, processTargetService: self.processTargetService, router: self.router))
//					iSnaps.append(object)
//			}
//		}
//
//		return (iSnaps, vms)
//	}
//
//	private func make(story: [ String : Any ]) -> (story: IStory, vm: StoryCollectionBaseCellVM)? {
//		guard let data = try? JSONSerialization.data(withJSONObject: story, options: []) else { return nil }
//		guard let typeString = story["type"] as? String, let type = StoryType(rawValue: typeString) else { return nil }
//
//		switch type {
//			case .firebaseInfo:
//				guard let object = try? JSONDecoder().decode(InfoStoryModel.self, from: data) else { return nil }
//				return (object, StoryInfoCellVM(infoStory: object))
//		}
//	}

}
