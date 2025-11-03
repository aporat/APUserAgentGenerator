import XCTest
@testable import APUserAgentGenerator

final class APAppUserAgentBuilderTests: XCTestCase {
    
    func testDefaultGeneration() async {
        let ua = APAppUserAgentBuilder.builder().generate()
        XCTAssertTrue(ua.starts(with: "App") || ua.starts(with: Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""), "User-Agent should start with default app name")
    }
    
    func testCustomAppUserAgent() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("MyApp")
            .withAppVersion("1.0")
            .withPlatform("iOS")
            .withPlatformArchitecture("arm64")
            .withPlatformVersion("18.4")
            .withBuildNumber("B123")
            .addPart("SDK/3.2")
            .addPart("ExtraInfo")
            .generate()
        
        let expected = "MyApp 1.0 (iOS; arm64; 18.4; B123; SDK/3.2; ExtraInfo)"
        XCTAssertEqual(ua, expected)
    }
    
    func testPartialFields() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("TestApp")
            .withPlatform("tvOS")
            .generate()
        
        XCTAssertTrue(ua.starts(with: "TestApp"))
        XCTAssertTrue(ua.contains("tvOS"))
    }
}
