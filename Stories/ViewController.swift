import UIKit
import VNBase
import SnapKit
import jetfire_sdk

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white

		let storiesView = Jetfire.standard.storiesView()
		self.view.addSubview(storiesView)
		storiesView.snp.makeConstraints { make in
			make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
			make.left.right.equalToSuperview()
		}

		let featureA = BlockButton { [weak self] _ in
			self?.showFeatureA()
		}
		featureA.apply(text: "Feature A", normal: .systemSemiBold24Black)
		self.view.addSubview(featureA)
		featureA.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().inset(240)
		}

		let featureB = BlockButton { [weak self] _ in
			self?.showFeatureB()
		}
		featureB.apply(text: "toaster_demo", normal: .systemSemiBold24Black)
		self.view.addSubview(featureB)
		featureB.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(featureA.snp.bottom).offset(48)
		}

		let featureC = BlockButton { [weak self] _ in
			self?.showFeatureC()
		}
		featureC.apply(text: "application_start", normal: .systemSemiBold24Black)
		self.view.addSubview(featureC)
		featureC.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(featureB.snp.bottom).offset(48)
		}
	}

	func showFeatureA() {
		let vc = FeatureAVC()
		self.navigationController?.push(vc)
	}

	func showFeatureB() {
        Jetfire.standard.trackStart(feature: "toaster_demo")
	}

	func showFeatureC() {
        Jetfire.standard.trackStart(feature: "application_start")
	}

}

