internal extension String {

	// Для Value
	static let kFail = "fail"
	static let kSuccess = "success"
	static let kSwipe = "swipe"
	static let kButton = "button"
	static let kGranted = "granted"
	static let kDenied = "denied"

	static let kYes = "yes"
	static let kNo = "no"

	// Featuring
	static let kPush = "push"
	static let kToaster = "toaster"
	
}

internal enum EventId: String {

	// System
	case jetfire_application_start
	case jetfire_become_active
	case jetfire_resign_active

	// Stories
	case jetfire_story_snap_show
	case jetfire_story_start_show
	case jetfire_story_finish_show
	case jetfire_story_close_tap
	case jetfire_story_cta_tap

	// Featuring Campaign
	case jetfire_featuring_campaign_show
	case jetfire_featuring_trigger_show

	// Feature tracking
	case jetfire_feature_start
	case jetfire_feature_finish

}

internal enum ParameterId: String {

	// Featuring
	case jetfire_featuring_id
	case jetfire_snap_index
	case jetfire_trigger_type
	case jetfire_featuring_type
	case jetfire_push_notifications

	// Track Features
	case jetfire_features_start
	case jetfire_features_finish

}
