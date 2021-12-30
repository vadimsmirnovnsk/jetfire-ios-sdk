import VNBase
import Foundation
import UIKit

/// Дефолтная вьюшка с папочками историй. Подлежит кастомизации
public class ContentStoriesView: BaseView<ContentStoriesVM> {

	private let collectionView = StoryCollectionView(viewModel: StoryCollectionVM())
	private let loader = UIActivityIndicatorView(style: .medium)

	public override var intrinsicContentSize: CGSize {
		CGSize(width: UIView.noIntrinsicMetric, height: Jetfire.standard.cover.size.height)
	}

	override init() {
		super.init()

		self.backgroundColor = Jetfire.standard.cover.bgColor
		self.collectionView.backgroundColor = Jetfire.standard.cover.bgColor

		self.collectionView.registerClasses([
			StoryInfoCell.self
		])

		self.addSubview(self.collectionView) { make in
			make.edges.equalToSuperview()
		}

		self.loader.hidesWhenStopped = true
		self.loader.tintColor = .white
		self.addSubview(self.loader) { make in
			make.center.equalToSuperview()
		}
	}

	public override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		if vm.shouldShowLoader {
			self.loader.startAnimating()
		} else {
			self.loader.stopAnimating()
		}

		self.collectionView.viewModel.items = vm.stories
//			self.collectionView.viewModel.sections = [TableSectionVM(rows: vm.stories)]
		print(">>> Loaded \(vm.stories.count) stories on Main thread \(Thread.current.isMainThread)")
	}

}

public class ContentStoriesVM: BaseVM {

	var shouldShowLoader: Bool { !self.storiesService.storageUpdated }
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
