import Foundation

final class JetfireAnalytics: IStoriesAnalytics {

	public var onLogEvent: ((_ name: EventId, _ params: [ ParameterId : Any ]) -> Void)?

	private let db: IDatabaseService

	init(db: IDatabaseService) {
		self.db = db
	}

	/// IStoriesAnalytics — трекаем и в базу и наружу, чтобы отправлять аналитику Jetfire во внешнюю систему аналитики.
	/// Соответствующие методы DB помечены приватными, чтобы не ошибиться при вызове методов
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

	func trackToastDidShow(campaignId: Int64) {
		self.onLogEvent?(.jetfire_toast_show, [
			.jetfire_campaign_id : campaignId
		])

		self.trackToasterShow(campaignId: campaignId)
	}

	func trackToastDidTap(campaignId: Int64) {
		self.onLogEvent?(.jetfire_toast_tap, [
			.jetfire_campaign_id : campaignId
		])

		self.trackToasterTap(campaignId: campaignId)
	}

	func trackPushDidShow(campaignId: Int64) {
		self.onLogEvent?(.jetfire_push_show, [
			.jetfire_campaign_id : campaignId
		])

		self.trackPushShow(campaignId: campaignId)
	}

	func trackPushDidTap(campaignId: Int64) {
		self.onLogEvent?(.jetfire_push_tap, [
			.jetfire_campaign_id : campaignId
		])

		self.trackPushTap(campaignId: campaignId)
	}

	/// DB

	// 0 - custom
	func trackCustomEvent(name: String, params: [ String : Any ]) {
		let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        let event = DBEvent(eventType: .custom, customEvent: name, data: jsonData)
		self.db.insertEvent(event)
	}

	// 1 - first_launch
	func trackFirstLaunch() {
        self.db.insertEvent(DBEvent(eventType: .firstLaunch))
	}

	// 2 - application_start
	func trackApplicationStart() {
		self.db.insert(eventType: .applicationStart)
	}

	// 3 - application_shutdown
	func trackApplicationShutdown() {
		self.db.insert(eventType: .applicationShutdown)
	}

	// 4 - feature_open
	func trackFeatureOpen(feature: String) {
        let event = DBEvent(eventType: .featureOpen, feature: feature)
		self.db.insertEvent(event)
	}

	// 5 - feature_close
	func trackFeatureClose(feature: String) {
        let event = DBEvent(eventType: .featureClose, feature: feature)
        self.db.insertEvent(event)
	}

	// 6 - feature_use
	func trackFeatureUse(feature: String) {
        let event = DBEvent(eventType: .featureUse, feature: feature)
        self.db.insertEvent(event)
	}

	// 7 - story_open
	private func trackStoryOpen(
		campaignId: Int64, // Campaign.id
		entityId: String // == story_id FeatureStory.id:номер кадра 100:0
	) {
        let event = DBEvent(eventType: .storyOpen, campaignId: campaignId, entityId: entityId)
        self.db.insertEvent(event)
	}

	// 8 - story_tap
	private func trackStoryTap(
		campaignId: Int64?,
		entityId: String
	) {
        let event = DBEvent(eventType: .storyTap, campaignId: campaignId, entityId: entityId)
        self.db.insertEvent(event)
	}

	// 9 - story_close
	private func trackStoryClose(
		campaignId: Int64?,
		entityId: String
	) {
        let event = DBEvent(eventType: .storyClose, campaignId: campaignId, entityId: entityId)
        self.db.insertEvent(event)
	}

	// 10 - push_show
	private func trackPushShow(campaignId: Int64?) {
        let event = DBEvent(eventType: .pushShow, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 11 - push_tap
	private func trackPushTap(campaignId: Int64?) {
        let event = DBEvent(eventType: .pushTap, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 12 - push_close
	private func trackPushClose(campaignId: Int64?) {
        let event = DBEvent(eventType: .pushClose, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 13 - toaster_show
	private func trackToasterShow(campaignId: Int64) {
        let event = DBEvent(eventType: .toasterShow, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 14 - toaster_tap
	private func trackToasterTap(campaignId: Int64) {
        let event = DBEvent(eventType: .toasterTap, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 15 - toaster_close
	private func trackToasterClose(campaignId: Int64) {
        let event = DBEvent(eventType: .toasterClose, campaignId: campaignId)
        self.db.insertEvent(event)
	}

	// 16 - feature_accepted
	func trackFeatureAccepted(
		campaignId: Int64?,
		feature: String,
		entityId: String?
	) {
        let event = DBEvent(eventType: .featureAccepted, campaignId: campaignId, feature: feature, entityId: entityId)
        self.db.insertEvent(event)
	}

    // 17 - jetfire_start
    func trackStart() {
        self.db.insertEvent(DBEvent(eventType: .jetfireStart))
    }

    // 18 - jetfire_featuring_start
    func trackFeaturingStart() {
        self.db.insertEvent(DBEvent(eventType: .jetfireFeaturingStart))
    }

}
