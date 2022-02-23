import Foundation

/// Раздает правила показа фичерингов
protocol IFeaturingRulesProvider {
    var rules: FeaturingRules { get }
}

// MARK: - FeaturingRulesProvider

class FeaturingRulesProvider: IFeaturingRulesProvider {
    #warning("Получать с бэкенда")
    let rules: FeaturingRules = .demo
}
