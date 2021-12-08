import UIKit
import VNBase
import SnapKit
import jetfire_sdk

class FeatureAVC: UIViewController {

	private let reviewService = PositiveReviewCommentGenerator()
	private let label = MultilineLabel()
	private let featureId = "toaster_demo"

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .storiesAlmostWhite
		self.title = "Toaster Demo"

		self.view.addSubview(self.label)
		self.label.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.top.equalToSuperview().inset(140)
		}

		let generate = BlockButton { [weak self] _ in
			self?.generate()
		}
		generate.apply(text: "Generate Review!", normal: .systemSemiBold24Black)
		self.view.addSubview(generate)
		generate.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-64)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		Jetfire.standard.trackStart(feature: self.featureId)
	}

	func generate() {
		let text = self.reviewService.generate(for: "John")
		self.label.apply(.systemSemiBold19Black, text: text, textAlignment: .center)

		Jetfire.standard.trackFinish(feature: self.featureId)
	}

}


