import VNBase
import UIKit

// Базовый класс коллекшен вьюхи с кругляшами
open class StoryCollectionView<TViewModel: StoryCollectionVM>: BaseCollectionView<TViewModel> {

	init(viewModel: TViewModel, layout: UICollectionViewFlowLayout = StoriesLayout()) {
		super.init(collectionViewLayout: layout, viewModel: viewModel)

		self.register(StoryCollectionBaseCell.self)

		self.isScrollEnabled = true
		self.showsHorizontalScrollIndicator = false
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = Jetfire.standard.storiesConfig.storyCircleBackgroundColor
		self.backgroundView = UIView()
		self.isUserInteractionEnabled = true
		self.isUpdateAnimated = true
	}

}

final class StoriesLayout: UICollectionViewFlowLayout {

	override init() {
		super.init()

		self.scrollDirection = .horizontal
		self.minimumInteritemSpacing = 0
		self.sectionInset = Jetfire.standard.storiesConfig.storyCircleCellInset
		self.itemSize = CGSize(
			width: Jetfire.standard.storiesConfig.storyCircleCellWidth,
			height: Jetfire.standard.storiesConfig.storyCircleCellHeight
		)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

open class StoryCollectionVM: BaseCollectionViewVM { }
