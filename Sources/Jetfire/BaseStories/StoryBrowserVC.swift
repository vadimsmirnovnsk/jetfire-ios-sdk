import VNBase
import VNEssential
import UIKit

class StoryBrowserCollectionView: BaseCollectionView<StoryBrowserCollectionVM> {

}

class StoryBrowserCollectionVM: BaseCollectionViewVM {

	public var onScrollToEnd: ((CGFloat) -> Void)?
	public var onScrollToTop: ((CGFloat) -> Void)?

}

final class StoryBrowserVC: BaseVC<StoryBrowserVM>, UIGestureRecognizerDelegate {

	override var navigationBarStyle: NavigationBarStyle? { .lightTransparent }

	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	override var prefersStatusBarHidden: Bool { !UIApplication.hasTopNotch }
	private let collection = StoryBrowserCollectionView(viewModel: StoryBrowserCollectionVM())

	private var didLayoutFirstTime: Bool = true

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .black

		self.collection.isScrollEnabled = true
		self.collection.showsVerticalScrollIndicator = false
        self.collection.showsHorizontalScrollIndicator = false
        self.collection.isPagingEnabled = true

		let layout = AnimatedCollectionViewLayout()
		layout.animator = CubeAttributesAnimator()
		layout.scrollDirection = .horizontal
		layout.sectionInset = .zero
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		self.collection.collectionViewLayout = layout

		self.collection.registerClasses([ StoryBrowserCell.self ])

		self.view.addSubview(self.collection) { make in
			if #available(iOS 11.0, *) {
				make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
			} else {
				make.edges.equalToSuperview()
			}
		}

		let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeDown))
		swipeDownRecognizer.direction = .down
		self.view.addGestureRecognizer(swipeDownRecognizer)

		let ghost = GhostRecognizer(gestureBlock: { [weak self] touch in
			if touch {
				self?.viewModel.pause()
			} else {
				self?.currentItem()?.goProgress(go: true)
			}
		})
		ghost.delegate = self
		self.view.addGestureRecognizer(ghost)

		let long = UILongPressGestureRecognizer()
		long.cancelsTouchesInView = true
		self.view.addGestureRecognizer(long)

		self.collection.viewModel.sections = [TableSectionVM(rows: self.viewModel.rows)]
		self.viewModel.browserDelegate = self
	}


	@objc private func didSwipeDown() {
		let vm = self.viewModel
		self.close { vm.didWatchStories() }
	}

	/// ВАЖНО! Единая верная точка для выхода из сториз!
	func close(completion: VoidBlock?) {
		self.currentItem()?.exit(completion: completion)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if self.didLayoutFirstTime {
			self.didLayoutFirstTime = false

			_ = self.collection.collectionViewLayout.collectionViewContentSize
			let initialIndexPath = IndexPath(row: self.viewModel.sinceIndex, section: 0)
			self.collection.scrollToItem(at: initialIndexPath, at: .centeredHorizontally,
										 animated: false)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.collection.viewModel.onScrollToEnd = { [weak self] in
			self?.didScrollToEdge(with: abs($0))
		}

		self.collection.viewModel.onScrollToTop = { [weak self] in
			self?.didScrollToEdge(with: abs($0))
		}

		self.currentItem()?.goProgress(go: true)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.pause()
	}

	private func didScrollToEdge(with offset: CGFloat) {
		if abs(offset) > 100 {
			self.close(completion: nil)
		}
	}

	private func currentItem() -> StoryBrowserCellVM? {
		let offset = self.collection.contentOffset.x
		let visibleCell = self.collection.visibleCells.sorted { (left, right) -> Bool in
			return abs(left.frame.origin.x - offset) < abs(right.frame.origin.x - offset)
		}.first

		guard let cell = visibleCell, let indexPath = self.collection.indexPath(for: cell),
			let vm = self.viewModel.rows.item(at: indexPath.row) else {
				return nil
		}

		return vm
	}

	func skip(cellVM: StoryBrowserCellVM) {
		if let index = self.viewModel.rows.indexes(of: cellVM).first {
			self.move(to: index + 1, animated: true)
		}
	}

	private func move(to index: Int, animated: Bool) {
		if self.viewModel.rows.item(at: index) != nil {
			self.collection.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
		} else {
			self.close(completion: nil)
		}
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

}

extension StoryBrowserVC: IStoryBrowserDelegate {

	func rewind(cellVM: StoryBrowserCellVM) -> Bool {
		if let index = self.viewModel.rows.indexes(of: cellVM).first, index - 1 >= 0 {
			self.move(to: index - 1, animated: true)
			return true
		}

		return false
	}


	func pause() {
		self.viewModel.pause()
	}

	func dismiss(completion: VoidBlock?) {
		self.dismiss(animated: true, completion: completion)
	}

}
