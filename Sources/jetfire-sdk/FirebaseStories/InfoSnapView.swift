import VNBase
import UIKit
import SDWebImage

final class InfoSnapView: BaseSnapView<InfoSnapVM> {

	private let backgroundImage = UIImageView()
	private let stack = UIStackView.stack(spacing: 0, alignment: .leading)
	private let title = MultilineLabel()
	private let subtitle = MultilineLabel()
	private let messageSpacing = UIView.stackSpacing(with: 16)
	private let message = MultilineLabel()
	private let buttonSpacing = UIView.stackSpacing(with: 24)
	private let button = InfoStoryButton()

	override init() {
		super.init()

		self.backgroundImage.contentMode = .scaleAspectFill
		self.backgroundImage.sd_imageTransition = .fade
		self.addSubview(self.backgroundImage) { make in
			make.edges.equalToSuperview()
		}

		self.addSubview(self.stack) { make in
			make.left.bottom.right.equalToSuperview().inset(32)
			make.top.greaterThanOrEqualToSuperview().offset(32)
		}

		self.title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.subtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.message.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.message.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		self.stack.addArrangedSubviews([
			self.title,
			self.subtitle,
			self.messageSpacing,
			self.message,
			self.buttonSpacing,
			self.button
		])

		self.button.onTap = { [weak self] _ in self?.viewModel?.didTapButton() }
		self.button.onTouch = { [weak self] in self?.viewModel?.didTouchButton() }
		self.bringSubviewsToFront = [self.button]
	}

	override func viewModelChanged() {
		super.viewModelChanged()

		guard let vm = self.viewModel else { return }

		self.backgroundColor = vm.snap.bgColor
		self.backgroundImage.sd_setImage(with: vm.snap.bgImageURL,
										 placeholderImage: nil,
										 options: [.transformAnimatedImage]) { _,_,_,_ in }

		self.title.isHidden = !vm.shouldShowTitle
		self.subtitle.isHidden = !vm.shouldShowSubtitle
		self.message.isHidden = !vm.shouldShowMessage
		self.messageSpacing.isHidden = !vm.shouldShowMessage
		self.button.isHidden = !vm.shouldShowButton
		self.buttonSpacing.isHidden = !vm.shouldShowButton

		self.title.apply(Jetfire.standard.firebaseConfig.firebaseStoryTitleTextStyle.with { $0.color = vm.snap.textColor },
						 text: vm.title)
		self.subtitle.apply(
			Jetfire.standard.firebaseConfig.firebaseStorySubitleTextStyle.with { $0.color = vm.snap.textColor.withAlphaComponent(0.5) },
			text: vm.subtitle
		)
		self.message.apply(Jetfire.standard.firebaseConfig.firebaseStorySubitleTextStyle.with { $0.color = vm.snap.textColor },
						   text: vm.message)
		self.button.title.apply(Jetfire.standard.firebaseConfig.firebaseStoryButtonTextStyle, text: vm.buttonTitle,
								textAlignment: .center)
	}

}

final class InfoSnapVM: BaseSnapVM {

	override var storyClass: (UIView & IHaveViewModel & IWantBringSubviewsToFront).Type { InfoSnapView.self }

	var shouldShowTitle: Bool { self.snap.title != nil }
	var title: String { self.snap.title ?? "" }

	var shouldShowSubtitle: Bool { self.snap.subtitle != nil }
	var subtitle: String { self.snap.subtitle ?? "" }

	var shouldShowMessage: Bool { self.snap.message != nil }
	var message: String { self.snap.message ?? "" }

	var shouldShowButton: Bool { self.snap.button != nil }
	var buttonTitle: String { self.snap.button?.title ?? "" }

	let snap: InfoSnap
	private let processTargetService: ProcessTargetService
	private let router: BaseRouter

	init(snap: InfoSnap, processTargetService: ProcessTargetService, router: BaseRouter) {
		self.snap = snap
		self.processTargetService = processTargetService
		self.router = router
	}

	func didTapButton() {
		guard let button = self.snap.button else { return }

		self.pause()

		if let shouldClose = button.closeStory, shouldClose {
			let targetService = self.processTargetService
			self.router.dismiss(animated: true) {
				targetService.process(button: button)
			}
		} else {
			self.processTargetService.process(button: button)
		}

		Jetfire.analytics.trackStoryDidTapButton(
			buttonOrSnapId: self.snap.button?.id ?? self.snap.id,
			buttonTitle: self.snap.button?.title ?? "Unknown"
		)
	}

	func didTouchButton() {
		FeedbackGeneratorService.tick()
	}

}
