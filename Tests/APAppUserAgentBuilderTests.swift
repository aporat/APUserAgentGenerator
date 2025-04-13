import XCTest
@testable import APUserAgentGenerator

final class APAppUserAgentBuilderTests: XCTestCase {

    func testDefaultGeneration() {
        let ua = APAppUserAgentBuilder.builder().generate()
        XCTAssertTrue(ua.starts(with: "App") || ua.starts(with: Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""), "User-Agent should start with default app name")
    }

    func testCustomAppUserAgent() {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("MyApp")
            .withAppVersion("1.0")
            .withPlatform("iOS")
            .withPlatformArchitecture("arm64")
            .withPlatformVersion("18.4")
            .addPart("SDK/3.2")
            .addPart("Build/567")
            .generate()

        let expected = "MyApp 1.0 (iOS; arm64; 18.4; SDK/3.2; Build/567)"
        XCTAssertEqual(ua, expected)
    }

    func testPartialFields() {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("TestApp")
            .withPlatform("tvOS")
            .generate()

        XCTAssertTrue(ua.starts(with: "TestApp"))
        XCTAssertTrue(ua.contains("tvOS"))
    }
}
