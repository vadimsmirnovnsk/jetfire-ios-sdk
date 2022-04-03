

/// Источник данных для карусели сторис
protocol IStoriesDataSource {
    var stories: [BaseStory] { get }
    var onChanged: Event<Void> { get }
}
