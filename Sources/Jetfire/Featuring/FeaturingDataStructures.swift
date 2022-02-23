import Foundation

enum FeaturingType: String, Codable {
	case applicationStart
	case push
	case toaster
	case deeplink
}

/// Общие правила показа фичеринговых кампаний
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
