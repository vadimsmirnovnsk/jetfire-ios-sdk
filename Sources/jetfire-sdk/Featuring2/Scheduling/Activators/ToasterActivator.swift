import Foundation

/// Активирует задание планировщика — показывает тостер
final class ToasterActivator: ISchedulerTaskActivator {

    private let campaignId: Int64
    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let factory: ToasterFactory
    private let jetfireAnalytics: JetfireAnalytics
    private let ud: IUserSettings
    private let rulesProvider: IFeaturingRulesProvider

    init(
        campaignId: Int64,
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        factory: ToasterFactory,
        jetfireAnalytics: JetfireAnalytics,
        ud: IUserSettings,
        rulesProvider: IFeaturingRulesProvider
    ) {
        self.campaignId = campaignId
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.factory = factory
        self.jetfireAnalytics = jetfireAnalytics
        self.ud = ud
        self.rulesProvider = rulesProvider
    }

    func activate() {
        let campaigns = self.triggeredCampaignsProvider.campaigns
        let campaign = campaigns.first { $0.id == self.campaignId }
        let toaster = campaign?.hasToaster == true ? campaign?.toaster : nil
        // Если на момент активации тостер не нашли в тригере,
        // значит состояние приложения поменялось, и тостер
        // уже не актуален, игнорируем его
        guard let campaign = campaign, let toaster = toaster else { return }
        // Если не можем показать тостер по причине защитных интервалов
        // по времени, игнорируем его
        guard self.canShowAnyToaster() && self.canShowToaster(campaignId: campaign.id) else { return }
        // Трекаем
        self.jetfireAnalytics.trackToasterShow(campaignId: campaign.id)
        self.ud.shownToasters[campaign.id] = Date()
        self.ud.lastToasterShowDate = Date()
        // Показываем
        Log.info("Activate toaster \(campaign.debugDescription)")
        let toasterView = self.factory.makeToaster(toaster: toaster, campaign: campaign)
        toasterView.show()
    }
}

// MARK: - Private

extension ToasterActivator {

    private func canShowAnyToaster() -> Bool {
        guard let date = self.ud.lastToasterShowDate else { return true }
        return Date().timeIntervalSince(date) > self.rulesProvider.rules.retryToasterShowTimeout
    }

    private func canShowToaster(campaignId: Int64) -> Bool {
        guard let date = self.ud.shownToasters[campaignId] else { return true }
        return Date().timeIntervalSince(date) > self.rulesProvider.rules.retryFeatureShowTimeout
    }
}
