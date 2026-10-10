@testable import APUserAgentGenerator
import Foundation
import Testing

@Suite("Browser / platform combinations")
struct CombinationTests {

    static func device(for platform: UAPlatform) -> any UADevice {
        switch platform {
        case .iOS: IOSDevice()
        case .macOS: MacDevice()
        case .android: AndroidDevice()
        case .windows: WindowsDevice()
        case .linux: LinuxDevice()
        }
    }

    @Test("Every supported combination builds a well-formed string", arguments: UAPlatform.allCases, BrowserType.allCases)
    func supported(platform: UAPlatform, kind: BrowserType) throws {
        guard platform.supports(kind) else { return }
        let ua = try BrowserUserAgent(device: Self.device(for: platform), browser: kind.browser)

        #expect(ua.platform == platform)
        #expect(ua.browser == kind)
        #expect(ua.value.hasPrefix("Mozilla/5.0 ("))
        #expect(ua.value.utf8.allSatisfy { (0x20...0x7E).contains($0) })
        #expect(!ua.value.contains("  "))
        #expect(!ua.value.hasSuffix(" "))
        #expect(ua.value.filter { $0 == "(" }.count == ua.value.filter { $0 == ")" }.count)
        #expect(ua.description == ua.value)
    }

    @Test("Every unsupported combination throws", arguments: UAPlatform.allCases, BrowserType.allCases)
    func unsupported(platform: UAPlatform, kind: BrowserType) {
        guard !platform.supports(kind) else { return }
        #expect(throws: UserAgentError.unsupportedCombination(browser: kind, platform: platform)) {
            try BrowserUserAgent(device: Self.device(for: platform), browser: kind.browser)
        }
    }

    @Test("Safari ships only on Apple platforms")
    func supportMatrix() {
        #expect(UAPlatform.iOS.supportedBrowsers == Set(BrowserType.allCases))
        #expect(UAPlatform.macOS.supportedBrowsers == Set(BrowserType.allCases))
        for platform in [UAPlatform.android, .windows, .linux] {
            #expect(!platform.supports(.safari))
            #expect(platform.supportedBrowsers.count == 4)
        }
        #expect(UAVersions.defaultVersion(for: .safari, on: .android) == nil)
        #expect(UAVersions.defaultVersion(for: .safari, on: .iOS) == nil)
        #expect(UAVersions.defaultVersion(for: .safari, on: .macOS) == UAVersions.safariMacOS)
    }

    @Test("Defaults: Safari on IOSDevice() at UAVersions.iOS, frozen")
    func defaults() throws {
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1"
        #expect(try BrowserUserAgent().value == expected)
        #expect(BrowserUserAgent.default.value == expected)
        #expect(try BrowserUserAgent.builder().build().value == expected)
        #expect(BrowserUserAgent.default.browserVersion == "27.0")
        #expect(IOSDevice().osVersion == UAVersions.iOS)
    }

    @Test("Builder is immutable and chainable")
    func builder() throws {
        let base = BrowserUserAgent.builder()
        let chrome = base.device(WindowsDevice()).browser(ChromeBrowser())
        #expect(base.device.platform == .iOS)
        #expect(chrome.device.platform == .windows)
        #expect(try chrome.build().value.contains("Chrome/\(UAVersions.chrome.split(separator: ".")[0]).0.0.0"))
    }

    @Test("Current defaults render as the vendors send them")
    func currentDefaults() throws {
        func ua(_ device: any UADevice, _ browser: any UABrowser) throws -> String {
            try BrowserUserAgent(device: device, browser: browser).value
        }
        #expect(try ua(WindowsDevice(), ChromeBrowser()).contains("Chrome/156.0.0.0 Safari/537.36"))
        #expect(try ua(AndroidDevice(), ChromeBrowser()).contains("Chrome/156.0.0.0 Mobile Safari/537.36"))
        #expect(try ua(IOSDevice(), ChromeBrowser()).contains("iPhone OS 27_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/155.0.8059.37 "))
        #expect(try ua(MacDevice(), FirefoxBrowser()).hasSuffix("rv:157.0) Gecko/20100101 Firefox/157.0"))
        #expect(try ua(IOSDevice(), FirefoxBrowser()).contains("FxiOS/157.1 Mobile/15E148 Safari/605.1.15"))
        #expect(try ua(WindowsDevice(), EdgeBrowser()).hasSuffix("Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0"))
        #expect(try ua(AndroidDevice(), EdgeBrowser()).hasSuffix("Chrome/154.0.0.0 Mobile Safari/537.36 EdgA/154.0.0.0"))
        #expect(try ua(IOSDevice(), EdgeBrowser()).contains("Version/27.0 EdgiOS/153.4234.46 Mobile/15E148 Safari/605.1.15"))
        #expect(try ua(LinuxDevice(), OperaBrowser()).hasSuffix("Chrome/153.0.0.0 Safari/537.36 OPR/137.0.0.0"))
        #expect(try ua(AndroidDevice(), OperaBrowser()).hasSuffix("Chrome/150.0.0.0 Mobile Safari/537.36 OPR/102.3.5206.90530"))
        #expect(try ua(IOSDevice(), OperaBrowser()).hasSuffix("Version/27.0 Mobile/15E148 Safari/604.1 OPT/6.7.3"))
        #expect(try ua(MacDevice(), SafariBrowser()).contains("Version/27.0 Safari/605.1.15"))
    }

    @Test("Embedded Chrome tokens follow version overrides")
    func embeddedChromeFollowsOverride() throws {
        func ua(_ device: any UADevice, _ browser: any UABrowser) throws -> String {
            try BrowserUserAgent(device: device, browser: browser).value
        }
        #expect(try ua(AndroidDevice(), EdgeBrowser(version: "149.0.3967.70")).hasSuffix("Chrome/149.0.0.0 Mobile Safari/537.36 EdgA/149.0.0.0"))
        #expect(try ua(MacDevice(), EdgeBrowser(version: "140")).hasSuffix("Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0"))
        #expect(try ua(WindowsDevice(), OperaBrowser(version: "120.0.5543.61")).hasSuffix("Chrome/136.0.0.0 Safari/537.36 OPR/120.0.0.0"))
        #expect(try ua(WindowsDevice(), OperaBrowser(version: "120", chromiumVersion: "135.0.7049.115")).hasSuffix("Chrome/135.0.0.0 Safari/537.36 OPR/120.0.0.0"))
        #expect(try ua(AndroidDevice(), OperaBrowser(version: "90.1.4718.86211")).hasSuffix("Chrome/138.0.0.0 Mobile Safari/537.36 OPR/90.1.4718.86211"))
    }

    @Test("Reported browserVersion is the unreduced value")
    func browserVersion() throws {
        #expect(try BrowserUserAgent(device: WindowsDevice(), browser: ChromeBrowser()).browserVersion == UAVersions.chrome)
        #expect(try BrowserUserAgent(device: IOSDevice(osVersion: "17.4.1"), browser: SafariBrowser()).browserVersion == "17.4")
        #expect(try BrowserUserAgent(device: IOSDevice(), browser: ChromeBrowser(version: "155")).browserVersion == "155.0.0.0")
    }
}
