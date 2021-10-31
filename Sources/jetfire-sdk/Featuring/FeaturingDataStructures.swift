import Foundation

/// Данные о доступных фичеринг-кампаниях для пользователя, обновляем их каждый запуск и в фоне
struct FeaturingData: Codable {

	/// Общие правила показа фичеринговых кампаний
	let rules: FeaturingRules

	/// Активные кампании, которые промотируются прямо сейчас
	let activeCampaigns: [FeaturingCampaign]

	/// Все кампании, доступные пользователю для промо
	let commonCampaigns: [FeaturingCampaign]

	func campaign(for campaignId: String) -> FeaturingCampaign? {
		return (self.activeCampaigns + self.commonCampaigns).first(where: { $0.id == campaignId })
	}

	static var demo: FeaturingData {
		return FeaturingData(
			rules: .demo,
			activeCampaigns: [.activeDemo],
			commonCampaigns: [.commonDemo]
		)
	}

}

/// Данные конкретной кампании
struct FeaturingCampaign: Codable {

	enum FeaturingType: String, Codable {
		case applicationStart
		case push
		case toaster
		case deeplink
	}

	/// Айдишник кампании
	let id: String
	/// Фича, которая промотируется в кампании
	let feature: String
	/// Фичи, с которыми связана кампания. Если пользователь сталкивается с ними в продукте, кампания может начаться
	let linkedFeatures: [String]
	/// Способы, которыми фича может быть промотирована
	let featuringTypes: [FeaturingType]
	/// Айдишник Firebase истории, которая соответствует кампании
	let storyId: String
	/// Приоритет кампании
	var priority: Int
	/// Пуш, планируемый для кампании
	var push: FeaturingPush?

	var hasPush: Bool { self.push != nil }

	static var activeDemo: FeaturingCampaign {
		return FeaturingCampaign(
			id: "cat_001",
			feature: "cat",
			linkedFeatures: ["animals"],
			featuringTypes: [.push, .applicationStart],
			storyId: "Demo Story 1",
			priority: 100,
			push: .demo
		)
	}

	static var commonDemo: FeaturingCampaign {
		return FeaturingCampaign(
			id: "platform_001",
			feature: "feature_a",
			linkedFeatures: ["platform"],
			featuringTypes: [.toaster, .push, .applicationStart],
			storyId: "discounts_spb_10",
			priority: 10,
			push: .demoCommon
		)
	}

}

struct FeaturingPush: Codable {

	let title: String
	let subtitle: String
	let body: String

	static var demo: FeaturingPush {
		return FeaturingPush(
			title: "Это демо-пуш активной кампании",
			subtitle: "Узнайте всё о приложении",
			body: "Заходите в приложение и вы увидите самую свежую новость про котика 🎉"
		)
	}

	static var demoCommon: FeaturingPush {
		return FeaturingPush(
			title: "Это демо-пуш общей кампании",
			subtitle: "Узнайте всё о приложении",
			body: "Заходите в приложение и вы увидите что-то про скидки 🥳"
		)
	}
}


/// Правила показа кампаний
struct FeaturingRules: Codable {

	enum ShowStyle: String, Codable {
		case crossDisolve
		case modal
	}

	/// Глобальный фиче-рубильник фичеринга
	let isFeaturingEnabled: Bool

	/// Признак режима теста для пользователя
	let isTest: Bool

	/// Способ появления фичеринга в лицо
	let featuringApplicationStartShowStyle: ShowStyle

	/// Таймаут для повторного фичеринга в лицо
	let retryApplicationStartShowTimeout: TimeInterval
	/// Таймаут для повторного фиче-пуша другой фичи
	let retryPushShowTimeout: TimeInterval
	/// Таймаут для повторного тостера другой фичи
	let retryToasterShowTimeout: TimeInterval

	/// Таймаут для повторного промо той же фичи любым способом
	let retryFeatureShowTimeout: TimeInterval

	static var demo: FeaturingRules {
		return FeaturingRules(
			isFeaturingEnabled: true,
			isTest: false,
			featuringApplicationStartShowStyle: .modal,
			retryApplicationStartShowTimeout: 60,
			retryPushShowTimeout: 60,
			retryToasterShowTimeout: 60,
			retryFeatureShowTimeout: 120
		)
	}

}
