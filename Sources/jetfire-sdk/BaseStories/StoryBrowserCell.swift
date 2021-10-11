import VNBase
import VNEssential
import UIKit

final class StoryBrowserCell: BaseCollectionViewCell<StoryBrowserCellVM>, SegmentedProgressBarDelegate {

	private var snapViews: [UIView&IHaveViewModel] = []
	private let topGradient = GradientView.verticalGray()
	private let snapsContainer = UIView()
	private var progressBar: SegmentedProgressBar? = nil
	private let nextButton = BlockButton()
	private let backButton = BlockButton()
	private let closeButton = BlockButton()

	public override class func size(with viewModel: StoryBrowserCellVM, size: CGSize) -> CGSize {
		return size
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.contentView.backgroundColor = .black
		self.contentView.layer.cornerRadius = 8
		self.contentView.layer.masksToBounds = true

		self.contentView.addSubview(self.snapsContainer) { make in
			make.edges.equalToSuperview()
		}

		self.contentView.addSubview(self.topGradient) { make in
			make.left.top.right.equalToSuperview()
			make.height.equalTo(64)
		}

		self.contentView.addSubview(self.nextButton) { make in
			make.top.right.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0))
			make.width.equalToSuperview().multipliedBy(0.75)
		}

		self.contentView.addSubview(self.backButton) { make in
			make.top.left.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0))
			make.width.equalToSuperview().multipliedBy(0.25)
		}

		self.closeButton.setImage(UIImage(named: "closeButton")?.colorized(with: .white),
								  for: .normal)
		self.contentView.addSubview(self.closeButton) { make in
			make.right.top.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 8))
		}

		self.nextButton.onTap = { [weak self] _ in self?.switchToNextSnap() }
		self.backButton.onTap = { [weak self] _ in self?.switchToPreviousSnap() }
		self.closeButton.onTap = { [weak self] _ in self?.viewModel?.exit()}
	}

	override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.progressBar?.removeFromSuperview()
		self.snapViews.forEach { $0.removeFromSuperview() }
		self.snapViews.removeAll()

		let progress = SegmentedProgressBar(numberOfSegments: vm.story.snaps.count,
											duration: vm.story.content.story.duration)
		self.progressBar = progress
		progress.topColor = Jetfire.standard.storiesConfig.progressBarTopColor
		progress.bottomColor = Jetfire.standard.storiesConfig.progressBarBottomColor
		progress.delegate = self
		self.topGradient.addSubview(progress) { make in
			make.left.top.right.equalToSuperview().inset(8)
			make.height.equalTo(2)
		}

		progress.setNeedsLayout()
		progress.layoutIfNeeded()
		DispatchQueue.main.async {
			progress.startAnimation(from: vm.index)
		}

		vm.animateBlock = { go in
			progress.isPaused = !go
		}
	}

	private func switchToPreviousSnap() {
		guard let vm = self.viewModel else { return }
		guard let progress = self.progressBar else { return }

		if progress.currentAnimationIndex == 0 {
			if !vm.switchToPreviousStory()  {
				self.progressBar?.rewind()
			}
		} else {
			self.progressBar?.rewind()
		}
	}

	private func switchToNextSnap() {
		self.progressBar?.skip()
	}

	/// MARK: SegmentedProgressBarDelegate

	func segmentedProgressBarChangedIndex(index: Int) {
		self.viewModel?.willShowSnap(at: index)

		if let snap = self.layoutedSnapView(for: index) {
			if index >= self.snapViews.count - 1 {
				self.viewModel?.read()
			}
			self.snapsContainer.bringSubviewToFront(snap)
			/// Это чтоб кнопки в снэпе были выше кнопок навигации
//			snap.bringSubviewsToFront.forEach { self.contentView.bringSubviewToFront($0) }
		}
	}

	private func layoutedSnapView(for index: Int) -> UIView? {
		guard let snapObject = self.viewModel?.story.snaps.safeObject(at: index) else { return nil }
		if let snap = self.snapViews.first(where: { $0.viewModelObject === snapObject.snapVM }) { return snap }

		let snap = snapObject.makeShit()
		self.snapViews.append(snap)

		let width = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
		self.snapsContainer.addSubview(snap) { make in
			make.edges.equalToSuperview()
			make.width.equalTo(width)
		}

		return snap
	}

	func segmentedProgressBarFinished() {
		self.viewModel?.switchToNextStory()
	}

}

final class StoryBrowserCellVM: BaseCellVM {

	var currentIndex: Int? = nil
	var index: Int {
		if let currentIndex = self.currentIndex { return currentIndex }
		if let alwaysZero = self.story.content.story.alwaysRewind, alwaysZero { return 0 }

		return self.story.snaps.firstIndex { !$0.snapVM.isRead } ?? 0
	}
	
	let story: BaseStory
	var animateBlock: BoolBlock? = nil
	weak var delegate: IStoryBrowserDelegate? = nil

	init(story: BaseStory) {
		self.story = story

		super.init()

		self.story.snaps.forEach { $0.snapVM.onPause = { [weak self] in self?.pause() } }
	}

	override func appear() {
		super.appear()

		self.story.snaps.forEach { $0.snapVM.downloadContentIfNeeded() }
	}

	func goProgress(go: Bool) {
		self.animateBlock?(go)
	}

	func switchToNextStory() {
//		guard self.isVisible else { return } // >>> 123

		self.story.snaps.last?.snapVM.isRead = true
		self.delegate?.skip(cellVM: self)
	}

	func switchToPreviousStory() -> Bool {
		guard self.isVisible else { return false }

		return self.delegate?.rewind(cellVM: self) ?? false
	}

	func read() {
		self.story.mark(read: true)
	}

	func pause() {
		self.delegate?.pause()
	}

	func willShowSnap(at index: Int) {
		self.currentIndex = index
		self.story.willAppearSnap(with: index)
	}

	func exit() {
		self.delegate?.close()
	}

}
