import Foundation
import VNEssential

/// Раздает доступные кампании
protocol IAvailableCampaignsProvider {
    var campaigns: [JetFireCampaign] { get }
    var onChanged: Event<Void> { get }
}

// MARK: - AvailableCampaignsProvider

final class AvailableCampaignsProvider: IAvailableCampaignsProvider {

    private let campaignsProvider: ICampaignsProvider
    private let db: DBAnalytics

    var campaigns: [JetFireCampaign] = []
    let onChanged: Event<Void> = Event()

    init(campaignsProvider: ICampaignsProvider, db: DBAnalytics) {
        self.campaignsProvider = campaignsProvider
        self.db = db

        self.db.onChanged.add(self) { [weak self] in
            self?.refresh()
        }
    }
}

// MARK: - Private

extension AvailableCampaignsProvider {

    func refresh() {
        self.campaignsProvider.fetchCampaigns { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newIds = Set(self.db.execute(sql: response.sql.available))
                let newCampaigns = response.campaigns.filter { newIds.contains($0.id) }
                let old = self.campaigns.map { $0.id }
                let new = newCampaigns.map { $0.id }
                self.campaigns = newCampaigns
                if old != new {
                    self.onChanged.raise(())
                }
            case .failure:
                break
            }
        }
    }
}