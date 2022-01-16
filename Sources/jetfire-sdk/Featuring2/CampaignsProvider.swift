import Foundation
import VNEssential

/// Отдает все кампании с бэка
protocol ICampaignsProvider {
    func fetchCampaigns(completion: @escaping (Result<JetFireListCampaignsResponse, Error>) -> Void)
}

// MARK: - CampaignsProvider

final class CampaignsProvider: ICampaignsProvider {

    private let api: IFeaturingAPI

    init(api: IFeaturingAPI) {
        self.api = api
    }

    func fetchCampaigns(completion: @escaping (Result<JetFireListCampaignsResponse, Error>) -> Void) {
        self.api.fetchCampaigns(completion: completion)
    }
}

// MARK: - CachedCampaignsProvider

final class CachedCampaignsProvider: ICampaignsProvider {

    private let campaignsProvider: ICampaignsProvider
    private var cache: JetFireListCampaignsResponse?

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(campaignsProvider: ICampaignsProvider) {
        self.campaignsProvider = campaignsProvider
    }

    func fetchCampaigns(completion: @escaping (Result<JetFireListCampaignsResponse, Error>) -> Void) {
        let operation = AsyncBlockOperation { [weak self] operationCompletion in
            guard let self = self else { return }
            if let cache = self.cache {
                completion(.success(cache))
                operationCompletion()
            } else {
                self.campaignsProvider.fetchCampaigns { response in
                    switch response {
                    case .success(let result):
                        self.cache = result
                        completion(.success(result))
                        operationCompletion()
                    case .failure(let error):
                        completion(.failure(error))
                        operationCompletion()
                    }
                }
            }
        }
        queue.addOperation(operation)
    }
}
