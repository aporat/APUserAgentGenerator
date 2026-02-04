import Foundation

// MARK: - Enums

public enum BrowserType: CaseIterable, Sendable {
    case safari, chrome, firefox, edge, opera
}

// MARK: - Protocols

public protocol UABrowser: Sendable {
    /// The browser's version, which is now optional again.
    var version: String? { get }

    /// Returns the appropriate version string for a given device platform.
    func version(for device: UADevice) -> String

    /// Generates the platform-specific part of the User-Agent string.
    func userAgentPlatformInfo(for device: UADevice) -> String

    var browserType: BrowserType { get }
}

// MARK: - Concrete Browsers

public struct SafariBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .safari }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        // Use user-provided version if it exists, otherwise fall back to defaults.
        if let userVersion = self.version {
            return userVersion
        }
        switch device {
        case is MacDevice: return "19.1"
        default: return "19.0" // iOS and fallback
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = self.version(for: device)
        switch device {
        case is IOSDevice:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(platformVersion) Mobile/15E148 Safari/604.1"
        case is MacDevice:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(platformVersion) Safari/605.1.15"
        default:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(platformVersion) Mobile/15E148 Safari/604.1"
        }
    }
}

public struct ChromeBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .chrome }

    public init(version: String? = nil) {
        self.version = version
    }

    public func version(for device: UADevice) -> String {
        if let userVersion = self.version {
            return userVersion
        }
        switch device {
        case is IOSDevice: return "148.0.7526.93"
        case is AndroidDevice: return "148.0.7526.100"
        default: return "149.0.0.0" // Desktop
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = self.version(for: device)
        switch device {
        case is IOSDevice:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/\(platformVersion) Mobile/15E148 Safari/604.1"
        case is AndroidDevice:
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(platformVersion) Mobile Safari/537.36"
        default:
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(platformVersion) Safari/537.36"
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
        if let userVersion = self.version {
            return userVersion
        }
        // Firefox uses a consistent version number across platforms in this example
        return "148.0"
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = self.version(for: device)
        switch device {
        case is IOSDevice:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/\(platformVersion) Mobile/15E148 Safari/604.1"
        case is AndroidDevice:
            return "Gecko/\(platformVersion) Firefox/\(platformVersion)"
        default: // Mac, Windows, Linux
            return "Gecko/20100101 Firefox/\(platformVersion)"
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
        if let userVersion = self.version {
            return userVersion
        }
        switch device {
        case is IOSDevice: return "148.0.2739.40"
        default: return "148.0.2739.45" // Desktop
        }
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = self.version(for: device)
        switch device {
        case is IOSDevice:
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) EdgiOS/\(platformVersion) Mobile/15E148 Safari/604.1"
        default:
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/\(platformVersion)"
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
        if let userVersion = self.version {
            return userVersion
        }
        return "134.0"
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let platformVersion = self.version(for: device)
        let chromeVersion = "148.0.0.0" // Opera's UA string often includes a recent Chrome version
        switch device {
        case is IOSDevice:
            let iosUA = "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1"
            return "\(iosUA) OPT/\(platformVersion)"
        case is AndroidDevice:
            let androidUA = "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(chromeVersion) Mobile Safari/537.36"
            return "\(androidUA) OPR/\(platformVersion).0.0"
        default:
            let desktopUA = "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(chromeVersion) Safari/537.36"
            return "\(desktopUA) OPR/\(platformVersion).0.0"
        }
    }
}
