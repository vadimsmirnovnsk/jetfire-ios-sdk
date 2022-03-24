import VNBase
import VNEssential
import UIKit
import SwiftProtobuf
import SDWebImage

/// Визуальный стиль — какая подложка (для адаптации к светлой/тёмной теме)
public enum ToastVisualStyle {
	case light
	case dark
	case color(UIColor)

	var bgColor: UIColor {
		switch self {
			case .light: return .clear
			case .dark: return .clear
			case .color(let c): return c
		}
	}

	var feedbackType: UINotificationFeedbackGenerator.FeedbackType { .success }
}

class ToasterView: UIView {

	/// Поведение тостера — исчезающий или ждущий обязательного действия (будет с кнопками, но пока нет)
	enum Behavior {
		case dismissable(message: String, imageURL: URL?, completion: VoidBlock)
		case concrete(message: String, imageURL: URL?, button: String, closeButton: String?, completion: VoidBlock)

		var text: String {
			switch self {
				case .dismissable(let message, _, _): return message
				case .concrete(let message, _, _, _, _): return message
			}
		}

		var buttonTitle: String {
			switch self {
				case .dismissable: return ""
				case .concrete(_, _, let button, _, _): return button
			}
		}

		var closeButtonTitle: String {
			switch self {
				case .dismissable: return ""
				case .concrete(message: _, imageURL: _, button: _, let closeButton, completion: _): return closeButton ?? ""
			}
		}

		var completion: VoidBlock? {
			switch self {
				case .dismissable(message: _, imageURL: _, let completion): return completion
				case .concrete(message: _, imageURL: _, button: _, closeButton: _, let completion): return completion
			}
		}

		var imageURL: URL? {
			switch self {
				case .dismissable(message: _, let imageURL, completion: _): return imageURL
				case .concrete(message: _, let imageURL, button: _, closeButton: _, completion: _): return imageURL
			}
		}	
	}

	private let kTopSpringOffset: CGFloat = 32

	let messageLabel = MultilineLabel()
	let okButton = BlockButton()
	let cancelButton = BlockButton()
	let toaster = UIView()
	let image = UIImageView()

	private var config: ToastStyle
	private var completion: VoidBlock?
	private let behavior: Behavior
	private let visualStyle: ToastVisualStyle

	init(config: ToastStyle, behavior: Behavior, visualStyle: ToastVisualStyle) {
		self.config = config
		self.behavior = behavior
		self.visualStyle = visualStyle

		super.init(frame: .zero)
		self.isUserInteractionEnabled = true

		self.addSubview(self.toaster) { (make) in
			make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.config.styleInset.top)
			make.left.equalToSuperview().inset(self.config.styleInset.left)
			make.right.equalToSuperview().inset(self.config.styleInset.right)
		}

		let bg: UIView
		switch visualStyle {
			case .color(let c):
				bg = GradientView(
					colors: [c, c],
					points: .horisontal
				)
			case .dark:
				bg = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
			case .light:
				bg = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
		}

		self.toaster.addSubview(bg) {
			$0.edges.equalToSuperview()
		}

		self.messageLabel.apply(self.config.textStyle, text: behavior.text)
		self.messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		self.messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
		self.messageLabel.textAlignment = self.config.textAlignment
		self.messageLabel.numberOfLines = self.config.numberOfLines
		self.toaster.addSubview(self.messageLabel) { make in
			make.top.equalToSuperview().offset(self.config.textInset.top)
			make.left.equalToSuperview().offset(self.config.textInset.left)
			make.right.lessThanOrEqualToSuperview().offset(-self.config.textInset.right).dgs_priority751()
			make.bottom.equalToSuperview().offset(-self.config.textInset.bottom)
		}

		if self.behavior.imageURL != nil {
			self.image.setCornerRadius(self.config.image.cornerRadius)
			self.image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
			self.image.setContentHuggingPriority(.defaultHigh, for: .vertical)
			self.image.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
			self.image.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
			self.image.sd_setImage(with: self.behavior.imageURL, completed: nil)
			self.toaster.addSubview(self.image) { make in
				make.size.equalTo(self.config.image.size)
				make.top.right.equalToSuperview().inset(self.config.image.inset)
				make.bottom.lessThanOrEqualToSuperview().inset(self.config.image.inset).dgs_priority250()
				make.left.greaterThanOrEqualTo(self.messageLabel.snp.right).offset(self.config.image.inset.left)
			}
		}

		if self.config.hasShadow {
			self.toaster.addShadow(color: UIColor.black.withAlphaComponent(0.3),
								   offset: CGSize(width: 0.0, height: 2.0), radius: 2.0)
		}

		self.toaster.transform = CGAffineTransform(translationX: 0, y: -70)
		self.completion = behavior.completion

		let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeUp))
		swipeGR.direction = .up
		self.toaster.addGestureRecognizer(swipeGR)

		let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
		tapGR.numberOfTapsRequired = 1
		self.toaster.addGestureRecognizer(tapGR)

		UIView.animate(withDuration: self.config.animation.duration,
					   delay: self.config.animation.delay,
					   usingSpringWithDamping: self.config.animation.usingSpringWithDamping,
					   initialSpringVelocity: self.config.animation.initialSpringVelocity,
					   options: [],
					   animations: {
				self.toaster.transform = .identity
			}, completion: nil)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.toaster.setCornerRadius(self.config.cornerRadius)
	}

	@objc private func didSwipeUp() {
		switch self.behavior {
			case .concrete:
				#warning("Когда появятся кнопки, переделать на break")
				self.dismiss()
			case .dismissable:
				self.dismiss()
		}
	}

	@objc private func didTap() {
		switch self.behavior {
			case .concrete:
				#warning("Когда появятся кнопки, переделать на break")
				self.completion?()
				self.dismiss()
			case .dismissable:
				self.completion?()
				self.dismiss()
		}
	}

	func show() {
		guard let window = UIApplication.keyWindow() else { return }

		window.addSubview(self)
		self.snp.makeConstraints { (make) in
			make.edges.equalTo(window)
		}

		if case .dismissable = self.behavior {
			DispatchQueue.main.asyncAfter(deadline: .now() + self.config.autoHideTime) { [weak self] in
				self?.dismiss()
			}
		}

		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(self.visualStyle.feedbackType)
	}

	func dismiss() {
		UIView.animate(
			withDuration: 0.25,
			delay: 0,
			options: [ .curveEaseOut ],
			animations: {
				self.toaster.transform = CGAffineTransform(
					translationX: 0,
					y: -self.toaster.frame.height - self.safeAreaInsets.top - 10
				)
			}, completion: { (_) in
				self.removeFromSuperview()
			})
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
