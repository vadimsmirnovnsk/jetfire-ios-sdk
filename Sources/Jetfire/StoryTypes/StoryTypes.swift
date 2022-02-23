/// Типы историй, которые грузим из джсона и заранее не знаем, что там за история
enum StoryType: String, Codable {
	case firebaseInfo = "info"
//	case userStory = "user"
}

/// Типы снапов, которые грузим из джсона и заранее не знаем, что там за снап
enum SnapType: String, Codable {
	case info
//	case user
//	case poll // Теоретический снап, его нет
}

// Теоретический снап, его пока не бывает
struct PollSnap: Codable, ISnap {
	let id: String
	let type: SnapType
	let title: String
	let subtitle: String
	let questions: [String]
}

