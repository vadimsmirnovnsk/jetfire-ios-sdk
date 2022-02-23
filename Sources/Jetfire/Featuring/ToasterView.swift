import VNBase
import VNEssential
import UIKit

class ToasterView: UIView {

	enum Style {
		case dismissable(String)
		case concrete(String)
		case button(title: String, button: String, completion: VoidBlock)

		var text: String {
			switch self {
				case .dismissable(let text): return text
				case .concrete(let text): return text
				case .button(title: let title, button: _, completion: _): return title
			}
		}

		var buttonTitle: String {
			switch self {
				case .dismissable, .concrete: return ""
				case .button(title: _, button: let title, completion: _): return title
			}
		}

		var completion: VoidBlock? {
			switch self {
				case .dismissable, .concrete: return nil
				case .button(title: _, button: _, completion: let completion): return completion
			}
		}
	}

	enum VisualStyle {
		case green
		case orange

		var bgColor: ColorGradient {
			switch self {
				case .green: return .FlashGreen
				case .orange: return .CommonOrange
			}
		}

		var feedbackType: UINotificationFeedbackGenerator.FeedbackType {
			switch self {
				case .green: return .success
				case .orange: return .error
			}
		}
	}

	private let kTopSpringOffset: CGFloat = 32

	let titleLabel = MultilineLabel()
	let toaster = UIView()
	private var completion: VoidBlock?
	private let style: Style
	private let visualStyle: VisualStyle

	init(style: Style, visualStyle: VisualStyle = .green) {
		self.style = style
		self.visualStyle = visualStyle

		super.init(frame: .zero)
		self.isUserInteractionEnabled = true

		self.addSubview(self.toaster) { (make) in
			make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(8)
			make.leading.trailing.equalToSuperview().inset(20)
		}

		let bg = GradientView(
			colors: [self.visualStyle.bgColor.to, self.visualStyle.bgColor.from],
			points: .horisontal
		)
		self.toaster.addSubview(bg) {
			$0.edges.equalToSuperview()
		}

		self.titleLabel.apply(.system14White, text: style.text)
		self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
		self.titleLabel.textAlignment = .center
		self.titleLabel.numberOfLines = 5
		self.toaster.addSubview(self.titleLabel) { make in
			make.leading.equalToSuperview().offset(24)
			make.trailing.equalToSuperview().offset(-24)
			make.top.equalToSuperview().offset(16)
			make.bottom.equalToSuperview().offset(-16)
		}

		self.toaster.addShadow(color: UIColor.black.withAlphaComponent(0.3),
							  offset: CGSize(width: 0.0, height: 2.0), radius: 2.0)
		self.toaster.transform = CGAffineTransform(translationX: 0, y: -70)
		self.completion = style.completion

		UIView.animate(withDuration: 0.37,
					   delay: 0.0,
					   usingSpringWithDamping: 0.7,
					   initialSpringVelocity: 0.3,
					   options: [],
					   animations: {
				self.toaster.transform = .identity
			}, completion: nil)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.toaster.setCornerRadius(20)
	}

	@objc private func tap() {
		self.completion?()
		self.dismiss()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		switch self.style {
			case .button: self.tap()
			case .concrete: break
			case .dismissable: self.dismiss()
		}
	}

	func show() {
		guard let window = UIApplication.keyWindow() else { return }

		window.addSubview(self)
		self.snp.makeConstraints { (make) in
			make.edges.equalTo(window)
		}

		if case .dismissable = self.style {
			DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
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
