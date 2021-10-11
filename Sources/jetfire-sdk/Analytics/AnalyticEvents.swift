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
	case firetest_application_start
	case firetest_become_active
	case firetest_resign_active

	// Stories
	case firetest_story_snap_show
	case firetest_story_start_show
	case firetest_story_finish_show
	case firetest_story_close_tap
	case firetest_story_cta_tap

	// Featuring Campaign
	case firetest_featuring_campaign_show
	case firetest_featuring_trigger_show

	// Feature tracking
	case firetest_feature_start
	case firetest_feature_finish

}

internal enum ParameterId: String {

	// Featuring
	case firetest_featuring_id
	case firetest_snap_index
	case firetest_trigger_type
	case firetest_featuring_type
	case firetest_push_notifications

	// Track Features
	case firetest_features_start
	case firetest_features_finish

}
