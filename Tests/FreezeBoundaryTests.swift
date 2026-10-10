@testable import APUserAgentGenerator
import Testing

@Suite("Platform freeze boundaries")
struct FreezeBoundaryTests {

    private func ua(_ device: any UADevice, _ browser: any UABrowser) throws -> String {
        try BrowserUserAgent(device: device, browser: browser).value
    }

    private static let webKitBrowsers: [any UABrowser] = [
        SafariBrowser(), FirefoxBrowser(), EdgeBrowser(), OperaBrowser()
    ]

    @Test("The last pre-freeze iOS reports its real full version", arguments: ["25.9.9", "18.7.3", "17.0"])
    func beforeFreeze(version: String) throws {
        let underscored = version.replacingOccurrences(of: ".", with: "_")
        for browser in Self.webKitBrowsers {
            #expect(try ua(IOSDevice(osVersion: version), browser).contains("iPhone OS \(underscored) like"))
        }
    }

    @Test("iOS 26 and later report the frozen token", arguments: ["26", "26.0", "26.7.1", "27.0.1", "40.2"])
    func fromFreeze(version: String) throws {
        for browser in Self.webKitBrowsers {
            #expect(try ua(IOSDevice(osVersion: version), browser).contains("iPhone OS 18_7 like"))
        }
    }

    @Test("The freeze follows the device, not a browser version override")
    func freezeFollowsDevice() throws {
        // 1.x froze an iOS 17 device whenever the Safari default was >= 26.
        #expect(try ua(IOSDevice(osVersion: "17.4"), FirefoxBrowser(version: "157.0")).contains("iPhone OS 17_4 like"))
        #expect(try ua(IOSDevice(osVersion: "17.4"), EdgeBrowser()).contains("Version/17.0 EdgiOS/"))
        #expect(try ua(IOSDevice(osVersion: "27.0"), EdgeBrowser()).contains("iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 EdgiOS/"))
    }

    @Test("Chrome for iOS is never frozen and always sends three OS components", arguments: [
        ("17", "17_0_0"), ("17.4", "17_4_0"), ("17.4.1", "17_4_1"), ("26.0", "26_0_0"), ("27.0.1", "27_0_1"), ("27.0.1.5", "27_0_1")
    ])
    func chromeNeverFrozen(version: String, expected: String) throws {
        #expect(try ua(IOSDevice(osVersion: version), ChromeBrowser()).contains("iPhone OS \(expected) like"))
    }

    @Test("WebKit pads a bare major to major_0")
    func webKitMinimumTwoComponents() throws {
        #expect(try ua(IOSDevice(osVersion: "17"), SafariBrowser()).contains("iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 "))
    }

    @Test("macOS is frozen for every browser")
    func macFrozen() throws {
        for kind in BrowserType.allCases {
            let value = try ua(MacDevice(), kind.browser)
            #expect(value.contains(kind == .firefox ? "Intel Mac OS X 10.15;" : "Intel Mac OS X 10_15_7)"))
        }
    }

    @Test("Android without a model sends the reduced token, ignoring osVersion")
    func androidReduced() throws {
        let value = try ua(AndroidDevice(osVersion: "17"), ChromeBrowser())
        #expect(value.hasPrefix("Mozilla/5.0 (Linux; Android 10; K) "))
    }

    @Test("Android with a model sends the full token")
    func androidFull() throws {
        let value = try ua(AndroidDevice(model: "Pixel 10 Pro", osVersion: "17"), ChromeBrowser(version: "156.0.8078.25"))
        #expect(value == "Mozilla/5.0 (Linux; Android 17; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36")
        #expect(try ua(AndroidDevice(model: "SM-S938B"), ChromeBrowser()).contains("(Linux; Android \(UAVersions.android); SM-S938B)"))
    }
}
