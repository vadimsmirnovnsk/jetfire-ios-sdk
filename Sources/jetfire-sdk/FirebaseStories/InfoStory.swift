//import UIColor_Hex_Swift
import UIKit

struct InfoStoryModel: Codable, IStory {

	let id: String
	let type: StoryType
	let title: String
	let duration: TimeInterval
	let priority: Int
	let image: String?
	let bgColorString: String?
	let afterReadTime: TimeInterval?
	let isTest: Bool?
	let alwaysRewind: Bool?
	let cityId: [Int64]?
	var startVersion: Int?

	var lifetime: TimeInterval { self.afterReadTime ?? 7 }

	var imageURL: URL? {
		guard let url = self.image else { return nil }
		return URL(string: url)
	}

	var bgColor: UIColor {
		guard let colorString = self.bgColorString else { return .gray }
		#warning("123")
		return .white // UIColor("#" + colorString, defaultColor: .gray)
	}

	enum CodingKeys: String, CodingKey {
		case id
		case type
		case title
		case duration
		case priority
		case image
		case bgColorString = "bg_color"
		case afterReadTime = "after_read_time"
		case isTest = "is_test"
		case alwaysRewind = "always_rewind"
		case cityId = "city_id"
		case startVersion = "start_version"
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
	let type: SnapType
	let title: String?
	let subtitle: String?
	let message: String?
	let bgColorString: String?
	let bgImageString: String?
	let textColorString: String?
	let button: StoryButton?

	var bgColor: UIColor {
		guard let colorString = self.bgColorString else { return .gray }
		#warning("123")
		return .white // UIColor("#" + colorString, defaultColor: .gray)
	}

	var bgImageURL: URL? {
		guard let url = self.bgImageString else { return nil }
		return URL(string: url)
	}

	var textColor: UIColor {
		guard let colorString = self.textColorString else { return .white }
		#warning("123")
		return .white // UIColor("#" + colorString, defaultColor: .white)
	}

	enum CodingKeys: String, CodingKey {
		case id
		case type
		case title
		case subtitle
		case message
		case bgColorString = "bg_color"
		case button
		case bgImageString = "bg_image"
		case textColorString = "text_color"
    }
}
