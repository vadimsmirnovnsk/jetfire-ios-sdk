import Foundation
import VNEssential

/// Раздает кампании для карусели сторис
protocol IStoriesCampaignsProvider {
    var campaigns: [JetFireCampaign] { get }
    var onUpdate: Event<Void> { get }
}

// MARK: - StoriesCampaignsProvider

final class StoriesCampaignsProvider: IStoriesCampaignsProvider {

    private let campaignsProvider: ICampaignsProvider
    private let db: IDatabaseService

    var campaigns: [JetFireCampaign] = []
    let onUpdate: Event<Void> = Event()

    init(campaignsProvider: ICampaignsProvider, db: IDatabaseService) {
        self.campaignsProvider = campaignsProvider
        self.db = db

        self.db.onChanged.add(self) { [weak self] in
            self?.refresh()
        }
    }
}

// MARK: - Private

extension StoriesCampaignsProvider {

    func refresh() {
        self.campaignsProvider.fetchCampaigns { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newIds = Set(self.db.execute(sql: response.sql.stories))
                let newCampaigns = response.campaigns.filter { newIds.contains($0.id) }
                let old = self.campaigns.map { $0.id }
                let new = newCampaigns.map { $0.id }
                self.campaigns = newCampaigns
                let changed = old != new
                if changed {
                    Log.info("Stories campaigns changed: \(newCampaigns.debugDescription)")
                    DispatchQueue.main.async {
                        self.onUpdate.raise(())
                    }
                }
            case .failure:
                break
            }
        }
    }
}
