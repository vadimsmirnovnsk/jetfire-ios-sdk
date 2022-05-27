import Foundation
import JetfireVNEssential

/// Раздает тригернутые кампании
protocol ITriggeredCampaignsProvider {
    var campaigns: [JetFireCampaign] { get }
    var onUpdate: Event<Void> { get }
    func refresh()
    func start()
}

// MARK: - TriggeredCampaignsProvider

final class TriggeredCampaignsProvider: ITriggeredCampaignsProvider {

    private let campaignsProvider: ICampaignsProvider
    private let db: IDatabaseService
    private var started: Bool = false

    var campaigns: [JetFireCampaign] = []
    let onUpdate: Event<Void> = Event()

    init(campaignsProvider: ICampaignsProvider, db: IDatabaseService) {
        self.campaignsProvider = campaignsProvider
        self.db = db
    }

    func start() {
        guard !self.started else { return }
        self.started = true
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
                let changed = old != new
                if changed {
                    Log.info("Triggered campaigns changed: \(newCampaigns.debugDescription)")
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
