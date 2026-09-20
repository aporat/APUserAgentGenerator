@testable import APUserAgentGenerator
import Testing

@Suite("Web Browser User Agent Builder")
struct APWebBrowserAgentBuilderTests {

    @Test("Default Configuration")
    func defaultGeneration() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .generate()

        // Safari 27 reports WebKit's frozen OS token rather than iOS 27.
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1"

        #expect(ua == expected)
    }

    // MARK: - Apple's iOS OS-version freeze

    @Test("Safari on iOS reports the frozen OS token, not the real version")
    func safariOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice(osVersion: "27.0"))
            .withBrowser(SafariBrowser(version: "27.0"))
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1"

        #expect(ua == expected)
    }

    @Test("Safari before 26 predates the freeze and uses the real OS version")
    func safariBeforeFreezeOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice(osVersion: "17.4"))
            .withBrowser(SafariBrowser(version: "17.4"))
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"

        #expect(ua == expected)
    }

    @Test("Safari version with non-numeric suffix still freezes when major parses")
    func safariVersionWithSuffixFreezes() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice(osVersion: "27.0"))
            .withBrowser(SafariBrowser(version: "27-beta"))
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27-beta Mobile/15E148 Safari/604.1"

        #expect(ua == expected)
    }

    @Test("Chrome on iOS builds its own UA and reports the real OS version")
    func chromeOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice(osVersion: "27.0"))
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 27_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/154.0.8037.41 Mobile/15E148 Safari/604.1"

        #expect(ua == expected)
    }

    @Test("Firefox on iOS renders with system WebKit and inherits the freeze")
    func firefoxOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice(osVersion: "27.0"))
            .withBrowser(FirefoxBrowser(version: "156.0"))
            .generate()

        // Firefox for iOS omits `Version/` and closes with Safari/605.1.15.
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/156.0 Mobile/15E148 Safari/605.1.15"

        #expect(ua == expected)
    }

    @Test("Edge on iOS carries Safari's Version token alongside EdgiOS")
    func edgeOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice())
            .withBrowser(EdgeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 EdgiOS/153.4234.46 Mobile/15E148 Safari/605.1.15"

        #expect(ua == expected)
    }

    @Test("Opera on iOS uses the OPT token")
    func operaOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(IOSDevice())
            .withBrowser(OperaBrowser())
            .generate()

        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1 OPT/6.6.2"

        #expect(ua == expected)
    }

    // MARK: - macOS

    @Test("Safari on Mac freezes the OS version at 10_15_7")
    func safariOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(SafariBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Safari/605.1.15"

        #expect(ua == expected)
    }

    @Test("Chrome on Mac freezes the OS version at 10_15_7")
    func chromeOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36"

        #expect(ua == expected)
    }

    @Test("Firefox on Mac reports the dotted frozen OS version")
    func firefoxOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(FirefoxBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:156.0) Gecko/20100101 Firefox/156.0"

        #expect(ua == expected)
    }

    @Test("An explicit Mac OS version overrides the frozen default")
    func macExplicitOSVersion() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice(osVersion: "14.6.1"))
            .withBrowser(SafariBrowser(version: "17.6"))
            .generate()

        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_6_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15"

        #expect(ua == expected)
    }

    // MARK: - Android

    @Test("Chrome on Android uses the reduced platform token by default")
    func chromeOnAndroidReduced() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice())
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36"

        #expect(ua == expected)
    }

    @Test("Naming a device model opts out of the reduced token")
    func chromeOnAndroidWithDeviceModel() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice(deviceModel: "Pixel 10 Pro"))
            .withBrowser(ChromeBrowser(version: "153.0.8010.49"))
            .generate()

        let expected = "Mozilla/5.0 (Linux; Android 17; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36"

        #expect(ua == expected)
    }

    @Test("The reduced token can be forced back on with a device model present")
    func androidReducedTokenOverride() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice(deviceModel: "Pixel 10 Pro", usesReducedPlatformToken: true))
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36"

        #expect(ua == expected)
    }

    @Test("Firefox on Android pins the OS token to 10 regardless of device")
    func firefoxOnAndroid() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice(deviceModel: "Pixel 10 Pro", osVersion: "17"))
            .withBrowser(FirefoxBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Android 10; Mobile; rv:156.0) Gecko/156.0 Firefox/156.0"

        #expect(ua == expected)
    }

    @Test("Edge on Android keeps the unreduced Chrome version")
    func edgeOnAndroid() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice())
            .withBrowser(EdgeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36 EdgA/153.0.4234.32"

        #expect(ua == expected)
    }

    @Test("Opera on Android preserves multi-segment version verbatim")
    func operaOnAndroidPreservesVersion() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice())
            .withBrowser(OperaBrowser(version: "115.0.5322.119"))
            .generate()

        let expected = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36 OPR/115.0.5322.119"

        #expect(ua == expected)
    }

    // MARK: - Desktop

    @Test("Chrome on Windows")
    func chromeOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36"

        #expect(ua == expected)
    }

    @Test("Firefox on Windows includes the rv token")
    func firefoxOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(FirefoxBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:156.0) Gecko/20100101 Firefox/156.0"

        #expect(ua == expected)
    }

    @Test("Edge on Windows reduces the embedded Chrome version to its own major")
    func edgeOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(EdgeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.4234.48"

        #expect(ua == expected)
    }

    @Test("Edge embedded Chrome version tracks Edge major")
    func edgeChromeMajorTracks() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(EdgeBrowser(version: "160.0.3000.10"))
            .generate()

        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/160.0.0.0 Safari/537.36 Edg/160.0.3000.10"

        #expect(ua == expected)
    }

    @Test("Opera on desktop embeds its Chromium base version")
    func operaOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(OperaBrowser())
            .generate()

        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 OPR/136.0.0.0"

        #expect(ua == expected)
    }

    @Test("Chrome on Linux")
    func chromeOnLinux() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(LinuxDevice())
            .withBrowser(ChromeBrowser())
            .generate()

        let expected = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36"

        #expect(ua == expected)
    }

    @Test("Firefox on Linux uses browser version for rv parameter")
    func firefoxOnLinux() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(LinuxDevice(osVersion: "7.0"))
            .withBrowser(FirefoxBrowser())
            .generate()

        // The Linux OS version is deliberately ignored; rv: carries Firefox's version.
        let expected = "Mozilla/5.0 (X11; Linux x86_64; rv:156.0) Gecko/20100101 Firefox/156.0"

        #expect(ua == expected)
    }

    // MARK: - Shape invariants

    @Test("Every browser and device combination produces a well-formed string", arguments: BrowserType.allCases)
    func everyCombinationIsWellFormed(browserType: BrowserType) {
        let devices: [UADevice] = [
            IOSDevice(),
            MacDevice(),
            AndroidDevice(),
            WindowsDevice(),
            LinuxDevice()
        ]

        for device in devices {
            let ua = APWebBrowserAgentBuilder(device: device, browser: browserType.browser).generate()

            #expect(ua.hasPrefix("Mozilla/5.0 ("))
            #expect(ua.filter { $0 == "(" }.count == ua.filter { $0 == ")" }.count)
            #expect(!ua.contains("  "))
            #expect(!ua.contains("()"))
            #expect(!ua.contains("//"))
        }
    }
}
