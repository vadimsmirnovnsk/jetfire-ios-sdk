import Foundation
/// Класс для трекинга аналитики. Трекаем аналитику только сюда
///
/// 1. Аналитика фич снаружи из приложения трекается в базу DBAnalytics
/// 2. Аналитика показов сториз трекается в базу и отправляется наружу

public protocol IJetfireAnalytics: AnyObject {

	var onLogEvent: ((_ name: EventId, _ params: [ ParameterId : Any ]) -> Void)? { get set }

	/// Логируем события, как в любую аналитику (для примера Firebase)
	func logEvent(_ name: String, parameters: [ String : Any ])

	/// Логируем проперти пользователя, как в любой аналитике (для примера Firebase)
	func setUserProperty(_ value: String, forName: String)

}

final class JetfireAnalytics: IJetfireAnalytics, IStoriesAnalytics {

	public var onLogEvent: ((_ name: EventId, _ params: [ ParameterId : Any ]) -> Void)?

	private let db: DBAnalytics

	init(db: DBAnalytics) {
		self.db = db
	}

	/// IJetfireAnalytics — трекаем в базу
	public func logEvent(_ name: String, parameters: [String : Any]) {
		self.trackCustomEvent(name: name, params: parameters)
	}

	public func setUserProperty(_ value: String, forName: String) {
		#warning("Need to be done")
	}

	/// IStoriesAnalytics — трекаем и в базу и наружу
	func trackStoryDidStartShow(storyId: String, campaignId: Int64) {
		self.onLogEvent?(.jetfire_story_start_show, [
			.jetfire_story_id : storyId,
			.jetfire_campaign_id : campaignId
		])
		self.trackStoryOpen(campaignId: campaignId, entityId: storyId)
	}

	func trackStorySnapDidShow(storyId: String, index: Int, campaignId: Int64) {
		self.onLogEvent?(.jetfire_story_snap_show, [
			.jetfire_story_id : storyId,
			.jetfire_campaign_id : campaignId,
			.jetfire_snap_index : index
		])
		self.trackStoryOpen(campaignId: campaignId, entityId: "\(storyId):\(index)")
	}

	func trackStoryDidFinishShow(storyId: String, campaignId: Int64) {
		self.onLogEvent?(.jetfire_story_finish_show, [
			.jetfire_story_id : storyId,
			.jetfire_campaign_id : campaignId,
		])
		self.trackStoryClose(campaignId: campaignId, entityId: storyId)
	}

	func trackStoryDidTapButton(storyId: String, index: Int, buttonTitle: String, campaignId: Int64) {
		self.onLogEvent?(.jetfire_story_cta_tap, [
			.jetfire_story_id : storyId,
			.jetfire_campaign_id : campaignId,
			.jetfire_snap_index : index,
			.jetfire_button_title : buttonTitle,
		])
		self.trackStoryTap(campaignId: campaignId, entityId: "\(storyId):\(index)")
	}

	/// DBAnalytics

	// 0 - custom
	func trackCustomEvent(name: String, params: [ String : Any ]) {
		let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
		self.db.track(
			eventType: .custom,
			campaignId: nil,
			feature: nil,
			featureId: nil,
			entityId: nil,
			customEvent: name,
			data: jsonData
		)
	}

	// 1 - first_launch
	func trackFirstLaunch() {
		self.db.track(eventType: .first_launch)
	}

	// 2 - application_start
	func trackApplicationStart() {
		self.db.track(eventType: .application_start)
	}

	// 3 - application_shutdown
	func trackApplicationShutdown() {
		self.db.track(eventType: .application_shutdown)
	}

	// 4 - feature_open
	func trackFeatureOpen(feature: String) {
		self.db.track(
			eventType: .feature_open,
			campaignId: nil,
			feature: feature,
			featureId: nil,
			entityId: nil
		)
	}

	// 5 - feature_close
	func trackFeatureClose(feature: String) {
		self.db.track(
			eventType: .feature_close,
			campaignId: nil,
			feature: feature,
			featureId: nil,
			entityId: nil
		)
	}

	// 6 - feature_use
	func trackFeatureUse(feature: String) {
		self.db.track(
			eventType: .feature_use,
			campaignId: nil,
			feature: feature,
			featureId: nil,
			entityId: nil
		)
	}

	// 7 - story_open
	func trackStoryOpen(
		campaignId: Int64, // Campaign.id
		entityId: String // == story_id FeatureStory.id:номер кадра 100:0
	) {
		self.db.track(
			eventType: .story_open,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: entityId
		)
	}

	// 8 - story_tap
	func trackStoryTap(
		campaignId: Int64?,
		entityId: String
	) {
		self.db.track(
			eventType: .story_tap,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: entityId
		)
	}

	// 9 - story_close
	func trackStoryClose(
		campaignId: Int64?,
		entityId: String
	) {
		self.db.track(
			eventType: .story_close,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: entityId
		)
	}

	// 10 - push_show
	func trackPushShow(campaignId: Int64?) {
		self.db.track(
			eventType: .push_show,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: nil
		)
	}

	// 11 - push_tap
	func trackPushTap(campaignId: Int64?) {
		self.db.track(
			eventType: .push_tap,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: nil
		)
	}

	// 12 - push_close
	func trackPushClose(campaignId: Int64?) {
		self.db.track(
			eventType: .push_close,
			campaignId: campaignId,
			feature: nil,
			featureId: nil,
			entityId: nil
		)
	}

	// 13 - toaster_show
	func trackToasterShow(campaignId: Int64) {
		self.db.track(
			eventType: .toaster_show,
			campaignId: campaignId
		)
	}

	// 14 - toaster_tap
	func trackToasterTap(campaignId: Int64) {
		self.db.track(
			eventType: .toaster_tap,
			campaignId: campaignId
		)
	}

	// 15 - toaster_close
	func trackToasterClose(campaignId: Int64) {
		self.db.track(
			eventType: .toaster_close,
			campaignId: campaignId
		)
	}

	// 16 - feature_accepted
	func trackFeatureAccepted(
		campaignId: Int64?,
		feature: String,
		featureId: Int,
		entityId: String?
	) {
		self.db.track(
			eventType: .feature_accepted,
			campaignId: campaignId,
			feature: feature,
			featureId: featureId,
			entityId: entityId
		)
	}

}
