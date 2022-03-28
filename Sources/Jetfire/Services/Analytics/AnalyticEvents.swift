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

public enum EventId: String {

	// Stories
	case jetfire_story_snap_show // ok
	case jetfire_story_start_show // ok
	case jetfire_story_finish_show // ok
	case jetfire_story_close // ok
	case jetfire_story_cta_tap // ok

	// Triggers
	case jetfire_toast_show // ok
	case jetfire_toast_tap // ok
	case jetfire_toast_close // ok
	case jetfire_toast_autoclose //  ok
	case jetfire_push_show
	case jetfire_push_tap // ok

}

public enum ParameterId: String {

	// Featuring
	case jetfire_story_id
	case jetfire_campaign_id
	case jetfire_snap_index
	case jetfire_button_title
	case jetfire_trigger_type
	case jetfire_featuring_type
	case jetfire_push_notifications
	case jetfire_timeout

	// Track Features
	case jetfire_features_start
	case jetfire_features_finish

}
