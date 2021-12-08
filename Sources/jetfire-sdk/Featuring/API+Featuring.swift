internal typealias FeaturingDataBlock = (JetFireListCampaignsResponse) -> Void

internal protocol IFeaturingAPI: AnyObject {
	/// Featuring
	func fetchCampaigns(completion: @escaping (Result<JetFireListCampaignsResponse, Error>) -> Void)
}
