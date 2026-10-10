import Foundation

/// A browser User-Agent, validated and rendered exactly like the real browser
/// would send it.
///
/// ```swift
/// let ua = try BrowserUserAgent(device: AndroidDevice(), browser: ChromeBrowser())
/// ua.value
/// // Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36
/// ```
///
/// Building throws ``UserAgentError`` for combinations no real browser
/// produces (Safari on Android), malformed versions or device models, and
/// inconsistent versions (a Safari 26 override on an iOS 17 device).
public struct BrowserUserAgent: UserAgent, Hashable {
    /// The rendered header value.
    public let value: String
    /// The platform of the device it was built for.
    public let platform: UAPlatform
    /// The browser it impersonates.
    public let browser: BrowserType
    /// The browser version after defaults were applied, unreduced
    /// (e.g. `"156.0.8078.12"` even though the string says `Chrome/156.0.0.0`).
    public let browserVersion: String

    /// Builds the User-Agent of `browser` running on `device`.
    public init(device: any UADevice = IOSDevice(), browser: any UABrowser = SafariBrowser()) throws {
        let rendered = try Renderer(device: device, browser: browser)
        self.value = rendered.value
        self.platform = device.platform
        self.browser = browser.kind
        self.browserVersion = rendered.browserVersion
    }

    /// Mobile Safari on an iPhone running ``UAVersions/iOS``.
    ///
    /// The defaults are covered by the test suite, so this never fails.
    public static var `default`: BrowserUserAgent {
        // swiftlint:disable:next force_try
        try! BrowserUserAgent()
    }

    /// Starts a chainable builder.
    public static func builder() -> Builder {
        Builder()
    }

    // MARK: - Builder

    /// A chainable, immutable builder. Defaults to Safari on ``IOSDevice()``.
    public struct Builder: Sendable {
        public private(set) var device: any UADevice = IOSDevice()
        public private(set) var browser: any UABrowser = SafariBrowser()

        public init() {}

        public func device(_ device: any UADevice) -> Builder {
            var copy = self
            copy.device = device
            return copy
        }

        public func browser(_ browser: any UABrowser) -> Builder {
            var copy = self
            copy.browser = browser
            return copy
        }

        public func build() throws -> BrowserUserAgent {
            try BrowserUserAgent(device: device, browser: browser)
        }
    }
}

// MARK: - Rendering

private struct Renderer {
    let value: String
    let browserVersion: String

    init(device: any UADevice, browser: any UABrowser) throws {
        let platform = device.platform
        let kind = browser.kind

        guard platform.supports(kind) else {
            throw UserAgentError.unsupportedCombination(browser: kind, platform: platform)
        }

        switch platform {
        case .iOS:
            let iOS = try Self.version(device.osVersion ?? UAVersions.iOS, field: "iOS")
            (value, browserVersion) = try Self.iOS(iOS, browser: browser)
        case .macOS:
            (value, browserVersion) = try Self.desktop(
                system: "Macintosh; Intel Mac OS X \(UAVersions.Frozen.macOSVersion)",
                firefoxSystem: "Macintosh; Intel Mac OS X \(UAVersions.Frozen.macOSVersionDotted)",
                platform: platform,
                browser: browser
            )
        case .windows:
            let system = "Windows NT \(UAVersions.Frozen.windowsNT); Win64; x64"
            (value, browserVersion) = try Self.desktop(
                system: system,
                firefoxSystem: system,
                platform: platform,
                browser: browser
            )
        case .linux:
            (value, browserVersion) = try Self.desktop(
                system: "X11; Linux x86_64",
                firefoxSystem: "X11; Linux x86_64",
                platform: platform,
                browser: browser
            )
        case .android:
            (value, browserVersion) = try Self.android(device: device, browser: browser)
        }
    }

    // MARK: Platforms

    private static func iOS(_ iOS: NumericVersion, browser: any UABrowser) throws -> (String, String) {
        let frozen = iOS.major >= UAVersions.Frozen.iOSFreezeMajor
        // WebKit sends the full marketing version (at least major_minor);
        // Chrome pads/truncates to exactly three components.
        let webKitOS = frozen ? UAVersions.Frozen.iOSVersion : iOS.formatted(separator: "_", minimum: 2, maximum: 3)
        let chromeOS = iOS.formatted(separator: "_", minimum: 3, maximum: 3)

        let engine = UAVersions.Engine.webKit
        let mobile = "Mobile/\(UAVersions.Engine.iOSBuild)"

        func ua(_ os: String, _ tail: String) -> String {
            "Mozilla/5.0 (iPhone; CPU iPhone OS \(os) like Mac OS X) \(engine) \(tail)"
        }

        switch browser.kind {
        case .safari:
            let safari: String
            if let override = browser.version {
                let parsed = try version(override, field: "Safari")
                guard parsed.major == iOS.major else {
                    throw UserAgentError.inconsistentVersions(
                        "Safari \(override) cannot run on iOS \(iOS.formatted()); Safari on iOS ships with the OS"
                    )
                }
                safari = parsed.formatted(minimum: 2, maximum: 3)
            } else {
                safari = iOS.majorMinor
            }
            return (ua(webKitOS, "Version/\(safari) \(mobile) \(UAVersions.Engine.safariMobile)"), safari)

        case .chrome:
            // CriOS always carries four components.
            let chrome = try resolved(browser, on: .iOS, minimum: 1).formatted(minimum: 4)
            return (ua(chromeOS, "CriOS/\(chrome) \(mobile) \(UAVersions.Engine.safariMobile)"), chrome)

        case .firefox:
            let firefox = try resolved(browser, on: .iOS, minimum: 1)
            return (ua(webKitOS, "FxiOS/\(firefox.formatted()) \(mobile) \(UAVersions.Engine.safariDesktop)"), firefox.formatted())

        case .edge:
            // EdgiOS always carries three components.
            let edge = try resolved(browser, on: .iOS, minimum: 1).formatted(minimum: 3)
            let tail = "Version/\(iOS.majorDotZero) EdgiOS/\(edge) \(mobile) \(UAVersions.Engine.safariDesktop)"
            return (ua(webKitOS, tail), edge)

        case .opera:
            let opera = try resolved(browser, on: .iOS, minimum: 1)
            let tail = "Version/\(iOS.majorDotZero) \(mobile) \(UAVersions.Engine.safariMobile) OPT/\(opera.formatted())"
            return (ua(webKitOS, tail), opera.formatted())
        }
    }

    private static func desktop(
        system: String,
        firefoxSystem: String,
        platform: UAPlatform,
        browser: any UABrowser
    ) throws -> (String, String) {
        let blink = UAVersions.Engine.blink
        let safari = UAVersions.Engine.safariBlink

        switch browser.kind {
        case .safari:
            // Only reachable on macOS (validated above).
            let version = try resolved(browser, on: platform, minimum: 1).formatted(minimum: 2, maximum: 3)
            let tail = "\(UAVersions.Engine.webKit) Version/\(version) \(UAVersions.Engine.safariDesktop)"
            return ("Mozilla/5.0 (\(system)) \(tail)", version)

        case .chrome:
            let chrome = try resolved(browser, on: platform, minimum: 1)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(chrome.reduced) \(safari)", chrome.formatted())

        case .firefox:
            let firefox = try resolved(browser, on: platform, minimum: 1)
            let rv = firefox.majorDotZero
            let ua = "Mozilla/5.0 (\(firefoxSystem); rv:\(rv)) Gecko/\(UAVersions.Engine.geckoTrail) Firefox/\(rv)"
            return (ua, firefox.formatted())

        case .edge:
            // Edge's Chromium major always equals its own major.
            let edge = try resolved(browser, on: platform, minimum: 1)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(edge.reduced) \(safari) Edg/\(edge.reduced)", edge.formatted())

        case .opera:
            let opera = try resolved(browser, on: platform, minimum: 1)
            let chromium = try operaChromium(browser, opera: opera, offset: UAVersions.operaChromiumOffset)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(chromium.reduced) \(safari) OPR/\(opera.reduced)", opera.formatted())
        }
    }

    private static func android(device: any UADevice, browser: any UABrowser) throws -> (String, String) {
        let system: String
        if let model = device.model {
            guard UserAgentValidation.isValidDeviceModel(model) else {
                throw UserAgentError.invalidDeviceModel(model)
            }
            let android = try version(device.osVersion ?? UAVersions.android, field: "Android")
            system = "Linux; Android \(android.formatted(maximum: 3)); \(model)"
        } else {
            // The real version is never sent with the reduced token, but a
            // malformed one is still a caller bug worth surfacing.
            if let osVersion = device.osVersion {
                _ = try version(osVersion, field: "Android")
            }
            system = "Linux; Android \(UAVersions.Frozen.androidVersion); \(UAVersions.Frozen.androidModel)"
        }

        let blink = UAVersions.Engine.blink
        let safari = "Mobile \(UAVersions.Engine.safariBlink)"

        switch browser.kind {
        case .safari:
            // Rejected by `UAPlatform.supports`; kept exhaustive on purpose.
            throw UserAgentError.unsupportedCombination(browser: .safari, platform: .android)

        case .chrome:
            let chrome = try resolved(browser, on: .android, minimum: 1)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(chrome.reduced) \(safari)", chrome.formatted())

        case .firefox:
            let firefox = try resolved(browser, on: .android, minimum: 1)
            let rv = firefox.majorDotZero
            let ua = "Mozilla/5.0 (Android \(UAVersions.Frozen.androidVersion); Mobile; rv:\(rv)) Gecko/\(rv) Firefox/\(rv)"
            return (ua, firefox.formatted())

        case .edge:
            let edge = try resolved(browser, on: .android, minimum: 1)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(edge.reduced) \(safari) EdgA/\(edge.reduced)", edge.formatted())

        case .opera:
            let opera = try resolved(browser, on: .android, minimum: 1)
            let chromium = try operaChromium(browser, opera: opera, offset: UAVersions.operaAndroidChromiumOffset)
            return ("Mozilla/5.0 (\(system)) \(blink) Chrome/\(chromium.reduced) \(safari) OPR/\(opera.formatted())", opera.formatted())
        }
    }

    // MARK: Versions

    private static func version(_ string: String, field: String, minimum: Int = 1) throws -> NumericVersion {
        guard let parsed = NumericVersion(string), parsed.components.count >= minimum else {
            throw UserAgentError.invalidVersion(field: field, value: string)
        }
        return parsed
    }

    /// The browser's override, or its default on `platform`, validated.
    private static func resolved(_ browser: any UABrowser, on platform: UAPlatform, minimum: Int) throws -> NumericVersion {
        guard let string = browser.version ?? UAVersions.defaultVersion(for: browser.kind, on: platform) else {
            throw UserAgentError.unsupportedCombination(browser: browser.kind, platform: platform)
        }
        return try version(string, field: browser.kind.rawValue.capitalized, minimum: minimum)
    }

    private static func operaChromium(_ browser: any UABrowser, opera: NumericVersion, offset: Int) throws -> NumericVersion {
        if let chromium = (browser as? OperaBrowser)?.chromiumVersion {
            return try version(chromium, field: "Opera Chromium")
        }
        // Derived, so overriding only the Opera version keeps both tokens consistent.
        return NumericVersion("\(opera.major + offset)") ?? opera
    }
}
