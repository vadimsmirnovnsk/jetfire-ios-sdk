import Foundation
import VNEssential

/// Раздает тригернутые кампании
protocol ITriggeredCampaignsProvider {
    var campaigns: [JetFireCampaign] { get }
    var onUpdate: Event<Bool> { get }
}

// MARK: - TriggeredCampaignsProvider

final class TriggeredCampaignsProvider: ITriggeredCampaignsProvider {

    private let campaignsProvider: ICampaignsProvider
    private let db: DBAnalytics

    var campaigns: [JetFireCampaign] = []
    let onUpdate: Event<Bool> = Event()

    init(campaignsProvider: ICampaignsProvider, db: DBAnalytics) {
        self.campaignsProvider = campaignsProvider
        self.db = db

        self.db.onChanged.add(self) { [weak self] in
            self?.refresh()
        }
    }
}

// MARK: - Private

extension TriggeredCampaignsProvider {

    func refresh() {
        self.campaignsProvider.fetchCampaigns { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newIds = Set(self.db.execute(sql: response.sql.trigger))
                let newCampaigns = response.campaigns.filter { newIds.contains($0.id) }
                let old = self.campaigns.map { $0.id }
                let new = newCampaigns.map { $0.id }
                self.campaigns = newCampaigns
                DispatchQueue.main.async {
                    self.onUpdate.raise(old != new)
                }
            case .failure:
                break
            }
        }
    }
}
