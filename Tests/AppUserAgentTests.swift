@testable import APUserAgentGenerator
import Foundation
import Testing

@Suite("App User-Agent")
struct AppUserAgentTests {

    static let environment = AppEnvironment(
        appName: "MyApp",
        appVersion: "1.4.2",
        buildNumber: "812",
        systemName: "iOS",
        systemVersion: "27.0.1",
        deviceModel: "iPhone17,1"
    )

    private var builder: AppUserAgent.Builder { AppUserAgent.builder(environment: Self.environment) }

    @Test("Auto-detected fields render in product form")
    func automatic() throws {
        #expect(try builder.build().value == "MyApp/1.4.2 (iOS 27.0.1; iPhone17,1; build:812)")
    }

    @Test("Custom fields and comments override detection")
    func custom() throws {
        let ua = try builder
            .appName("Other")
            .appVersion("2.0")
            .buildNumber("9")
            .systemName("iPadOS")
            .systemVersion("26.1")
            .deviceModel("iPad16,3")
            .addingComment("SDK/3.2")
            .addingComment("ExtraInfo")
            .build()
        #expect(ua.value == "Other/2.0 (iPadOS 26.1; iPad16,3; build:9; SDK/3.2; ExtraInfo)")
        #expect(ua.description == ua.value)
    }

    @Test("Every auto-detected field can be omitted")
    func omission() throws {
        #expect(try builder.omitting(.deviceModel).build().value == "MyApp/1.4.2 (iOS 27.0.1; build:812)")
        #expect(try builder.omitting(.buildNumber, .systemVersion).build().value == "MyApp/1.4.2 (iOS; iPhone17,1)")
        #expect(try builder.omitting(.systemName).build().value == "MyApp/1.4.2 (27.0.1; iPhone17,1; build:812)")
        #expect(try builder.omitting(.appVersion).build().value == "MyApp (iOS 27.0.1; iPhone17,1; build:812)")
        #expect(try builder.omitting(Field.allCases).build().value == "MyApp")
        #expect(try builder.omitting(Field.allCases).addingComment("SDK/3").build().value == "MyApp (SDK/3)")
    }

    @Test("Omitting a field wins over a custom value set earlier, and vice versa")
    func omissionOrder() throws {
        #expect(try builder.deviceModel("X").omitting(.deviceModel).build().value == "MyApp/1.4.2 (iOS 27.0.1; build:812)")
        #expect(try builder.omitting(.deviceModel).deviceModel("X").build().value == "MyApp/1.4.2 (iOS 27.0.1; X; build:812)")
    }

    @Test("Missing environment values are simply left out")
    func missing() throws {
        let ua = try AppUserAgent.builder(environment: AppEnvironment(appName: "Bare")).build()
        #expect(ua.value == "Bare")
    }

    @Test("Product token is percent-encoded like CFNetwork")
    func productEscaping() throws {
        let ua = try builder.appName("My App").appVersion("1.0 (beta)").omitting(Field.allCases.filter { $0 != .appVersion }).build()
        #expect(ua.value == "My%20App/1.0%20%28beta%29")
        #expect(try builder.appName("Café/Bar").omitting(Field.allCases).build().value == "Caf%C3%A9%2FBar")
        #expect(try builder.appName("100%").omitting(Field.allCases).build().value == "100%25")
    }

    @Test("Comment parts cannot break out of the comment or inject headers")
    func commentEscaping() throws {
        let ua = try builder
            .omitting(Field.allCases)
            .addingComment("a;b")
            .addingComment("(evil)")
            .addingComment("x\r\nX-Injected: 1")
            .addingComment("back\\slash")
            .addingComment("naïve")
            .addingComment("   ")
            .build()
        #expect(ua.value == "MyApp (a%3Bb; %28evil%29; x%0D%0AX-Injected: 1; back%5Cslash; na%C3%AFve)")
        #expect(!ua.value.contains("\r") && !ua.value.contains("\n"))
    }

    @Test("Every field is escaped, including auto-detected ones")
    func environmentEscaping() throws {
        let hostile = AppEnvironment(
            appName: "Evil\r\nApp",
            appVersion: "1\n",
            buildNumber: "7)",
            systemName: "i;OS",
            systemVersion: "1(2",
            deviceModel: "M\u{0}"
        )
        let ua = try AppUserAgent.builder(environment: hostile).build()
        #expect(ua.value == "Evil%0D%0AApp/1 (i%3BOS 1%282; M; build:7%29)")
        #expect(ua.value.utf8.allSatisfy { (0x20...0x7E).contains($0) })
    }

    @Test("Empty app names are rejected", arguments: ["", "   ", "\r\n"])
    func emptyName(_ name: String) {
        #expect(throws: UserAgentError.emptyAppName) {
            try builder.appName(name).build()
        }
    }

    @Test("AppEnvironment.current detects something sensible without UIKit or the main actor")
    func current() async throws {
        let environment = await Task.detached { AppEnvironment.current }.value
        #expect(environment.appName?.isEmpty == false)
        #expect(environment.systemName?.isEmpty == false)
        #expect(environment.deviceModel?.isEmpty == false)
        let version = try #require(environment.systemVersion)
        #expect(NumericVersion(version) != nil)

        let ua = try AppUserAgent.builder().build()
        #expect(ua.value.utf8.allSatisfy { (0x20...0x7E).contains($0) })
        #expect(!ua.value.isEmpty)
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @Test("IOSDevice.current reports the running iOS version")
    func iosCurrent() throws {
        let device = IOSDevice.current
        let expected = ProcessInfo.processInfo.operatingSystemVersion
        #expect(device.osVersion?.hasPrefix("\(expected.majorVersion).\(expected.minorVersion)") == true)
        #expect(try BrowserUserAgent(device: device, browser: ChromeBrowser()).value.contains("iPhone OS \(expected.majorVersion)_\(expected.minorVersion)_\(expected.patchVersion) like"))
    }
    #endif
}

private typealias Field = AppUserAgent.Field

extension AppUserAgent.Builder {
    fileprivate func omitting(_ fields: [Field]) -> Self {
        fields.reduce(self) { $0.omitting($1) }
    }
}
