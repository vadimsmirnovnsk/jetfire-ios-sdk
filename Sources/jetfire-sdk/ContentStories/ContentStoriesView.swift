import VNBase
import Foundation
import UIKit

/// Дефолтная вьюшка с папочками историй. Подлежит кастомизации
public class ContentStoriesView: BaseView<ContentStoriesVM> {

	private let collectionView = StoryCollectionView(viewModel: StoryCollectionVM())

	public override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: Jetfire.standard.storiesConfig.storyCircleCellHeight) }

	override init() {
		super.init()

		self.backgroundColor = Jetfire.standard.storiesConfig.storyCircleBackgroundColor

		self.collectionView.registerClasses([
			StoryInfoCell.self
		])

		self.addSubview(self.collectionView) { make in
			make.edges.equalToSuperview()
		}
	}

	public override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.collectionView.viewModel.sections = [TableSectionVM(rows: vm.stories)]
	}

}

public class ContentStoriesVM: BaseVM {

	var stories: [BaseCellVM] { self.storiesService.stories.map { $0.previewCellVM } }

	private let storiesService: StoriesService

	init(storiesService: StoriesService) {
		self.storiesService = storiesService

		super.init()

		self.storiesService.onChangeStories.add(self) { [weak self] in
			self?.reloadStories()
		}
	}

	private func reloadStories() {
		DispatchQueue.main.async {
			self.viewModelChanged()
		}
	}

}
