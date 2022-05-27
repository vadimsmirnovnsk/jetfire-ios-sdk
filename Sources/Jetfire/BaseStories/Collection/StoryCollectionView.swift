import JetfireVNBase
import UIKit

// Базовый класс коллекшен вьюхи с кругляшами
open class StoryCollectionView<TViewModel: StoryCollectionVM>: BaseCollectionView<TViewModel> {

	init(viewModel: TViewModel, layout: UICollectionViewFlowLayout = StoriesLayout()) {
		super.init(collectionViewLayout: layout, viewModel: viewModel)

		self.register(StoryCollectionBaseCell.self)

		self.isScrollEnabled = true
		self.showsHorizontalScrollIndicator = false
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = Jetfire.standard.cover.bgColor
		self.backgroundView = UIView()
		self.isUserInteractionEnabled = true
		self.isUpdateAnimated = true
	}

}

final class StoriesLayout: UICollectionViewFlowLayout {

	override init() {
		super.init()

		self.scrollDirection = .horizontal
		self.minimumInteritemSpacing = Jetfire.standard.cover.interItemOffset
		self.minimumLineSpacing = Jetfire.standard.cover.interItemOffset
		self.sectionInset = Jetfire.standard.cover.sectionInset
		self.itemSize = Jetfire.standard.cover.size
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

open class StoryCollectionVM: BaseCollectionViewVM { }
