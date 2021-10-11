import VNBase
import UIKit

extension CGFloat {
	static var kStoryWidth: CGFloat = 80
}

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
		self.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
		self.itemSize = CGSize(width: .kStoryWidth, height: 100)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

open class StoryCollectionVM: BaseCollectionViewVM { }
