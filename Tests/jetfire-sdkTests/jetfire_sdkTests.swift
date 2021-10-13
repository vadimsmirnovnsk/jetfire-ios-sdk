import XCTest
@testable import jetfire_sdk

final class jetfire_sdkTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Jetfire().text, "Hello, World!")
		let url = URL(string: "jetfiredemomock://jf?show_story=123123")!
		Jetfire.standard.deeplinkService.application(UIApplication.shared, open: url, options: [:])
    }
}
