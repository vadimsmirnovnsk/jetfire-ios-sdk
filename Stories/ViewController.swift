import UIKit
import VNBase
import SnapKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .lightGray

		let featureA = BlockButton { [weak self] _ in
			self?.showFeatureA()
		}
		featureA.apply(text: "Feature A", normal: .systemSemiBold24Black)
		self.view.addSubview(featureA)
		featureA.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().inset(140)
		}

		let featureB = BlockButton { [weak self] _ in
			self?.showFeatureB()
		}
		featureB.apply(text: "Feature B", normal: .systemSemiBold24Black)
		self.view.addSubview(featureB)
		featureB.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(featureA.snp.bottom).offset(48)
		}

		let featureC = BlockButton { [weak self] _ in
			self?.showFeatureC()
		}
		featureC.apply(text: "Feature C", normal: .systemSemiBold24Black)
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

	}

	func showFeatureC() {

	}

}

