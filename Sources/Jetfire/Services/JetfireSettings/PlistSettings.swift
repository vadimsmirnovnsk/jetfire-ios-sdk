import Foundation

/// Настройки SDK из plist
struct PlistSettings: Decodable {

    let apiKey: String
    let baseURLString: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "API_KEY"
        case baseURLString = "API_BASE_URL"
    }
}
