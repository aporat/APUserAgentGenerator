import Foundation

// MARK: - Enums

public enum BrowserType: CaseIterable, Sendable {
    case safari, chrome, firefox, edge, opera
}

public extension BrowserType {
    /// A browser of this type using the package's default versions.
    var browser: UABrowser {
        switch self {
        case .safari: SafariBrowser()
        case .chrome: ChromeBrowser()
        case .firefox: FirefoxBrowser()
        case .edge: EdgeBrowser()
        case .opera: OperaBrowser()
        }
    }
}

// MARK: - Protocols

public protocol UABrowser: Sendable {
    /// An explicit version override. When `nil`, ``version(for:)`` supplies a
    /// platform-appropriate default from ``UAVersions``.
    var version: String? { get }

    /// Returns the appropriate version string for a given device platform.
    func version(for device: UADevice) -> String

    /// Generates the platform-specific part of the User-Agent string.
    func userAgentPlatformInfo(for device: UADevice) -> String

    var browserType: BrowserType { get }

    /// Whether this browser renders with the system WebKit on iOS and therefore
    /// inherits Apple's frozen OS token.
    ///
    /// True for every iOS browser except Chrome, which assembles its own
    /// User-Agent and still reports the real iOS version.
    var usesSystemWebKitUserAgent: Bool { get }
}

public extension UABrowser {
    var usesSystemWebKitUserAgent: Bool { true }
}

// MARK: - Concrete Browsers

public struct SafariBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .safari }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        version ?? UAVersions.safari
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = version(for: device)
        let engine = UAVersions.Engine.webKit

        switch device {
        case is MacDevice:
            return "\(engine) Version/\(platformVersion) \(UAVersions.Engine.safariDesktop)"
        default:
            // iOS, and the fallback for platforms Safari does not ship on.
            return "\(engine) Version/\(platformVersion) Mobile/\(UAVersions.Engine.iOSBuild) \(UAVersions.Engine.safariMobile)"
        }
    }
}

public struct ChromeBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .chrome }

    /// Chrome for iOS builds its User-Agent itself rather than reusing WebKit's,
    /// so it is the one iOS browser that still reports the real OS version.
    public var usesSystemWebKitUserAgent: Bool { false }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        if let version {
            return version
        }
        switch device {
        case is IOSDevice: return UAVersions.chromeIOS
        case is AndroidDevice: return UAVersions.chromeAndroid
        default: return UAVersions.chromeDesktop
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = version(for: device)
        switch device {
        case is IOSDevice:
            return "\(UAVersions.Engine.webKit) CriOS/\(platformVersion) Mobile/\(UAVersions.Engine.iOSBuild) \(UAVersions.Engine.safariMobile)"
        case is AndroidDevice:
            return "\(UAVersions.Engine.blink) Chrome/\(platformVersion) Mobile \(UAVersions.Engine.safariBlink)"
        default:
            return "\(UAVersions.Engine.blink) Chrome/\(platformVersion) \(UAVersions.Engine.safariBlink)"
        }
    }
}

public struct FirefoxBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .firefox }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        // Firefox ships the same version number on every platform.
        version ?? UAVersions.firefox
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = version(for: device)
        switch device {
        case is IOSDevice:
            // Firefox for iOS omits the `Version/` token and, unlike Safari on
            // iOS, closes with Safari/605.1.15 rather than Safari/604.1.
            return "\(UAVersions.Engine.webKit) FxiOS/\(platformVersion) Mobile/\(UAVersions.Engine.iOSBuild) \(UAVersions.Engine.safariDesktop)"
        case is AndroidDevice:
            return "Gecko/\(platformVersion) Firefox/\(platformVersion)"
        default: // Mac, Windows, Linux
            return "Gecko/\(UAVersions.Engine.geckoTrail) Firefox/\(platformVersion)"
        }
    }
}

public struct EdgeBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .edge }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        if let version {
            return version
        }
        switch device {
        case is IOSDevice: return UAVersions.edgeIOS
        case is AndroidDevice: return UAVersions.edgeAndroid
        default: return UAVersions.edgeDesktop
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = version(for: device)

        switch device {
        case is IOSDevice:
            // Edge on iOS renders with system WebKit, so it carries Safari's
            // `Version/` token alongside its own `EdgiOS/` token.
            return "\(UAVersions.Engine.webKit) Version/\(UAVersions.safari) EdgiOS/\(platformVersion) Mobile/\(UAVersions.Engine.iOSBuild) \(UAVersions.Engine.safariDesktop)"
        case is AndroidDevice:
            // Android keeps the unreduced Chrome version.
            return "\(UAVersions.Engine.blink) Chrome/\(UAVersions.chromeAndroid) Mobile \(UAVersions.Engine.safariBlink) EdgA/\(platformVersion)"
        default:
            // Desktop Edge reduces the embedded Chrome version, whose major
            // always matches Edge's own.
            let chromeMajor = platformVersion.majorVersionComponent ?? String(UAVersions.safariMajor)
            return "\(UAVersions.Engine.blink) Chrome/\(chromeMajor).0.0.0 \(UAVersions.Engine.safariBlink) Edg/\(platformVersion)"
        }
    }
}

public struct OperaBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .opera }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        if let version {
            return version
        }
        switch device {
        case is IOSDevice: return UAVersions.operaIOS
        case is AndroidDevice: return UAVersions.operaAndroid
        default: return UAVersions.operaDesktop
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = version(for: device)
        switch device {
        case is IOSDevice:
            // Opera for iOS still reports the `OPT/` token it inherited from Opera Touch.
            let iosUA = "\(UAVersions.Engine.webKit) Version/\(UAVersions.safari) Mobile/\(UAVersions.Engine.iOSBuild) \(UAVersions.Engine.safariMobile)"
            return "\(iosUA) OPT/\(platformVersion)"
        case is AndroidDevice:
            let androidUA = "\(UAVersions.Engine.blink) Chrome/\(UAVersions.operaAndroidChrome) Mobile \(UAVersions.Engine.safariBlink)"
            return "\(androidUA) OPR/\(platformVersion)"
        default:
            let desktopUA = "\(UAVersions.Engine.blink) Chrome/\(UAVersions.operaDesktopChrome) \(UAVersions.Engine.safariBlink)"
            return "\(desktopUA) OPR/\(platformVersion)"
        }
    }
}
