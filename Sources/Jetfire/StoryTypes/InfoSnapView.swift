import VNBase
import UIKit
import SDWebImage

final class InfoSnapView: BaseSnapView<InfoSnapVM> {

	private let backgroundImage = UIImageView()
	private let stack = UIStackView.stack(spacing: 0, alignment: .leading)
	private let title = MultilineLabel()
	private let subtitle = MultilineLabel()
	private let messageSpacing = UIView.stackSpacing(with: Jetfire.standard.snap.messageSpacing)
	private let message = MultilineLabel()
	private let buttonSpacing = UIView.stackSpacing(with: Jetfire.standard.snap.buttonSpacing)
	private let button = InfoStoryButton(style: Jetfire.standard.snap.buttonStyle)

	override init() {
		super.init()

		self.backgroundImage.contentMode = .scaleAspectFill
		self.backgroundImage.sd_imageTransition = .fade
		self.addSubview(self.backgroundImage) { make in
			make.edges.equalToSuperview()
		}

		self.addSubview(self.stack) { make in
			make.left.bottom.right.equalToSuperview().inset(Jetfire.standard.snap.containerInsets)
			make.top.greaterThanOrEqualToSuperview().offset(Jetfire.standard.snap.containerInsets.top)
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

		/// va.smirnov: это нехорошо, делаю на бегу
		self.button.snp.makeConstraints { make in
			switch Jetfire.standard.snap.buttonStyle.behavior {
				case .fullscreen: make.width.equalToSuperview()
				case .part: break
			}
		}

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

		self.title.apply(Jetfire.standard.snap.titleStyle.with { $0.color = vm.snap.textColor },
						 text: vm.title)
		self.subtitle.apply(
			Jetfire.standard.snap.subtitleStyle.with { $0.color = vm.snap.textColor.withAlphaComponent(0.5) },
			text: vm.subtitle
		)
		self.message.apply(Jetfire.standard.snap.messageStyle.with { $0.color = vm.snap.textColor },
						   text: vm.message)
		self.button.title.apply(Jetfire.standard.snap.buttonStyle.titleStyle, text: vm.buttonTitle,
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
	private let analytics: IStoriesAnalytics

	init(snap: InfoSnap, processTargetService: ProcessTargetService, router: BaseRouter, analytics: IStoriesAnalytics) {
		self.snap = snap
		self.processTargetService = processTargetService
		self.router = router
		self.analytics = analytics
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

		self.analytics.trackStoryDidTapButton(
			storyId: self.snap.storyId,
			index: self.snap.index,
			buttonTitle: self.snap.button?.title ?? "Unknown",
			campaignId: self.snap.campaignId
		)
	}

	func didTouchButton() {
		FeedbackGeneratorService.tick()
	}

}
