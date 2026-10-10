@testable import APUserAgentGenerator
import Testing

/// Byte-for-byte comparisons against User-Agent strings published by the
/// vendors themselves, pinned to the version numbers in the source so the
/// tests do not churn when ``UAVersions`` is bumped.
@Suite("Golden real-browser User-Agents")
struct GoldenUserAgentTests {

    private func ua(_ device: any UADevice, _ browser: any UABrowser) throws -> String {
        try BrowserUserAgent(device: device, browser: browser).value
    }

    // MARK: Chromium
    // Source: chromium/src components/embedder_support/user_agent_utils.cc
    // (GetUnifiedPlatform) and content/common/user_agent.cc (BuildUserAgentFromOSAndProduct),
    // plus the Chrome UA-reduction spec: every Chrome/ token is <major>.0.0.0.

    @Test("Chrome on Windows (Chromium reduced UA)")
    func chromeWindows() throws {
        #expect(try ua(WindowsDevice(), ChromeBrowser(version: "120.0.6099.71"))
            == "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    }

    @Test("Chrome on macOS (Chromium reduced UA)")
    func chromeMac() throws {
        #expect(try ua(MacDevice(), ChromeBrowser(version: "120.0.6099.71"))
            == "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    }

    @Test("Chrome on Linux (Chromium reduced UA)")
    func chromeLinux() throws {
        #expect(try ua(LinuxDevice(), ChromeBrowser(version: "120.0.6099.71"))
            == "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    }

    @Test("Chrome on Android (Chromium reduced UA, full Android version hidden)")
    func chromeAndroid() throws {
        #expect(try ua(AndroidDevice(), ChromeBrowser(version: "120.0.6099.43"))
            == "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36")
    }

    // Source: chromium/src ios/web/common/user_agent.mm (BuildMobileUserAgent):
    // "Mozilla/5.0 (iPhone; CPU iPhone OS %s like Mac OS X) AppleWebKit/605.1.15
    // (KHTML, like Gecko) CriOS/%s Mobile/15E148 Safari/604.1", with the OS
    // version formatted as major_minor_bugfix.
    @Test("Chrome on iOS reports the real three-part OS version and full CriOS version")
    func chromeIOS() throws {
        #expect(try ua(IOSDevice(osVersion: "17.4.1"), ChromeBrowser(version: "123.0.6312.52"))
            == "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/123.0.6312.52 Mobile/15E148 Safari/604.1")
        #expect(try ua(IOSDevice(osVersion: "26.0"), ChromeBrowser(version: "140.0.7339.101"))
            == "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/140.0.7339.101 Mobile/15E148 Safari/604.1")
    }

    // MARK: Edge
    // Source: Microsoft Learn, "Detecting Microsoft Edge from your website"
    // (microsoft-edge/web-platform/user-agent-guidance.md).

    @Test("Edge on Windows (Microsoft Learn sample)")
    func edgeWindows() throws {
        #expect(try ua(WindowsDevice(), EdgeBrowser(version: "120.0.2210.61"))
            == "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0")
    }

    @Test("Edge on Android (Microsoft Learn sample)")
    func edgeAndroid() throws {
        #expect(try ua(AndroidDevice(), EdgeBrowser(version: "120.0.2210.84"))
            == "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 EdgA/120.0.0.0")
    }

    // MARK: Firefox
    // Source: MDN, "Firefox user agent string reference".

    @Test("Firefox on Windows x64 (MDN)")
    func firefoxWindows() throws {
        #expect(try ua(WindowsDevice(), FirefoxBrowser(version: "10.0"))
            == "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:10.0) Gecko/20100101 Firefox/10.0")
    }

    @Test("Firefox on macOS (MDN, frozen 10.15)")
    func firefoxMac() throws {
        #expect(try ua(MacDevice(), FirefoxBrowser(version: "10.0"))
            == "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:10.0) Gecko/20100101 Firefox/10.0")
    }

    @Test("Firefox on Linux x86_64 (MDN)")
    func firefoxLinux() throws {
        #expect(try ua(LinuxDevice(), FirefoxBrowser(version: "10.0"))
            == "Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0")
    }

    @Test("Firefox on Android phone (MDN shape, Android frozen to 10 since Firefox 122)")
    func firefoxAndroid() throws {
        #expect(try ua(AndroidDevice(model: "Pixel 8", osVersion: "14"), FirefoxBrowser(version: "125.0.2"))
            == "Mozilla/5.0 (Android 10; Mobile; rv:125.0) Gecko/125.0 Firefox/125.0")
    }

    @Test("Firefox for iOS (MDN shape with the modern 15E148 build token)")
    func firefoxIOS() throws {
        #expect(try ua(IOSDevice(osVersion: "17.4"), FirefoxBrowser(version: "124.0"))
            == "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/124.0 Mobile/15E148 Safari/605.1.15")
    }

    // MARK: Safari / WebKit
    // Source: WebKit Source/WebCore/platform/ios/UserAgentIOS.mm
    // (standardUserAgentWithApplicationName) + Safari's application name
    // "Version/<v> Mobile/15E148 Safari/604.1"; frozen token from WebKit's
    // iOS 26 UA change (webkit.org bug 298260 shows the iOS 26 shape).

    @Test("Safari on iOS 17 reports the real OS version")
    func safariIOS17() throws {
        #expect(try ua(IOSDevice(osVersion: "17.5.1"), SafariBrowser())
            == "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1")
    }

    @Test("Safari on iOS 26 reports the frozen 18_7 token")
    func safariIOS26() throws {
        #expect(try ua(IOSDevice(osVersion: "26.0"), SafariBrowser())
            == "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1")
    }

    @Test("Safari on macOS (frozen 10_15_7)")
    func safariMac() throws {
        #expect(try ua(MacDevice(), SafariBrowser(version: "17.4.1"))
            == "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15")
    }
}
