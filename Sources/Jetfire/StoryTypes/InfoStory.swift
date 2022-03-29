import UIColorHexSwift
import UIKit

struct InfoStoryModel: Codable, IStory {

	let id: String
	let campaignId: Int64
	let type: StoryType
	let title: String
	let duration: TimeInterval
	let priority: Int
	let image: String?
	let bgColorString: String?
	let afterReadTime: TimeInterval?
	let isTest: Bool?
	let alwaysRewind: Bool?

	var lifetime: TimeInterval { self.afterReadTime ?? 7 }

	var imageURL: URL? {
		guard let url = self.image else { return nil }
		return URL(string: url)
	}

	var bgColor: UIColor {
		guard let colorString = self.bgColorString else { return .clear }
		return UIColor(colorString, defaultColor: .clear)
	}

	enum CodingKeys: String, CodingKey {
		case id
		case campaignId = "campaign_id"
		case type
		case title
		case duration
		case priority
		case image
		case bgColorString = "bg_color"
		case afterReadTime = "after_read_time"
		case isTest = "is_test"
		case alwaysRewind = "always_rewind"
    }

}

struct StoryButton: Codable {
	public let id: String?
	public let title: String
	public let urlString: String?
	public let deeplinkString: String?
	public let closeStory: Bool?

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case urlString = "url"
		case deeplinkString = "deeplink"
		case closeStory
    }
}

struct InfoSnap: Codable, ISnap {
	let id: String
	let storyId: String
	let campaignId: Int64
	let index: Int
	let type: SnapType
	let title: String?
	let subtitle: String?
	let message: String?
	let bgColorString: String?
	let bgImageString: String?
	let textColorString: String?
	let duration: Double
	let button: StoryButton?

	var bgColor: UIColor {
		guard let colorString = self.bgColorString else { return .lightGray }
		return UIColor(colorString, defaultColor: .lightGray)
	}

	var bgImageURL: URL? {
		guard let url = self.bgImageString else { return nil }
		return URL(string: url)
	}

	var textColor: UIColor {
		guard let colorString = self.textColorString else { return .white }
		return UIColor(colorString, defaultColor: .white)
	}

	enum CodingKeys: String, CodingKey {
		case id
		case storyId
		case campaignId = "campaign_id"
		case index
		case type
		case title
		case subtitle
		case message
		case bgColorString = "bg_color"
		case button
		case bgImageString = "bg_image"
		case textColorString = "text_color"
		case duration
    }
}
