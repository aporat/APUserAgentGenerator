@testable import APUserAgentGenerator
import Foundation
import Testing

@Suite("App User Agent Builder")
@MainActor
struct APAppUserAgentBuilderTests {

    @Test("Default Generation starts with App Name")
    func defaultGeneration() async {
        let ua = APAppUserAgentBuilder.builder().generate()

        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""

        #expect(ua.starts(with: "App") || ua.starts(with: bundleName))
    }

    @Test("Custom App User Agent matches exact format")
    func customAppUserAgent() async {
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

        #expect(ua == expected)
    }

    @Test("Partial fields generation")
    func partialFields() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("TestApp")
            .withPlatform("tvOS")
            .generate()

        #expect(ua.starts(with: "TestApp"))
        #expect(ua.contains("tvOS"))
    }
}
