#if canImport(UIKit)
@testable import APUserAgentGenerator
import Foundation
import Testing

@Suite("App User Agent Builder")
@MainActor
struct APAppUserAgentBuilderTests {

    @Test("Default Generation starts with App Name")
    func defaultGeneration() async {
        let ua = APAppUserAgentBuilder.builder().generate()

        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"

        #expect(ua.starts(with: bundleName))
        #expect(ua.hasSuffix(")"))
    }

    @Test("Custom App User Agent matches exact format")
    func customAppUserAgent() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("MyApp")
            .withAppVersion("1.0")
            .withPlatform("iOS")
            .withPlatformArchitecture("arm64")
            .withPlatformVersion("27.0")
            .withBuildNumber("B123")
            .addPart("SDK/3.2")
            .addPart("ExtraInfo")
            .generate()

        let expected = "MyApp 1.0 (iOS; arm64; 27.0; B123; SDK/3.2; ExtraInfo)"

        #expect(ua == expected)
    }

    @Test("addPart sanitizes unsafe characters and drops empty input")
    func addPartSanitization() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("MyApp")
            .withAppVersion("1.0")
            .withPlatform("iOS")
            .withPlatformArchitecture("arm64")
            .withPlatformVersion("27.0")
            .withBuildNumber("B123")
            .addPart("   ")
            .addPart("a; X-Forwarded-For: 1.1.1.1")
            .addPart("(injected)")
            .generate()

        let expected = "MyApp 1.0 (iOS; arm64; 27.0; B123; a, X-Forwarded-For: 1.1.1.1; injected)"

        #expect(ua == expected)
    }

    @Test("Newlines are stripped so a token cannot inject a header")
    func controlCharactersAreStripped() async {
        let ua = APAppUserAgentBuilder
            .builder()
            .withAppName("My\r\nApp")
            .withAppVersion("1.0")
            .withPlatform("iOS")
            // Pin the auto-detected fields too, so the expectation does not
            // depend on whichever simulator the suite happens to run on.
            .withPlatformArchitecture("arm64")
            .withPlatformVersion("27.0")
            .withBuildNumber("B123")
            .addPart("ok\r\nX-Injected: yes")
            .generate()

        #expect(!ua.contains("\n"))
        #expect(!ua.contains("\r"))
        #expect(ua == "MyApp 1.0 (iOS; arm64; 27.0; B123; okX-Injected: yes)")
    }

    @Test("The initializer sanitizes too, not just the builder")
    func initializerSanitization() async {
        let ua = APAppUserAgentBuilder(
            appName: "My\nApp",
            appVersion: "1.0",
            buildNumber: "B1",
            platform: "iOS",
            platformArchitecture: "arm64",
            platformVersion: "27.0",
            extraParts: ["bad;part", "\r\n"]
        ).generate()

        #expect(ua == "MyApp 1.0 (iOS; arm64; 27.0; B1; bad,part)")
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
#endif
