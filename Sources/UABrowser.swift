import Foundation

// MARK: - Enums

public enum BrowserType: CaseIterable, Sendable {
    case safari, chrome, firefox, edge, opera
}

// MARK: - Protocols

public protocol UABrowser: Sendable {
    var version: String? { get }
    func userAgentPlatformInfo(for device: UADevice) -> String
    var browserType: BrowserType { get }
}

// MARK: - Concrete Browsers

public struct SafariBrowser: UABrowser {
    public var version: String?
    public var webkitVersion: String = "605.1.15"
    public var safariBuild: String = "604.1"
    public var kernelBuild: String = "15E148"
    public var browserType: BrowserType { .safari }

    public init(version: String? = nil) {
        self.version = version
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "18.4"
        if device is iOSDevice {
            return "AppleWebKit/\(webkitVersion) (KHTML, like Gecko) Version/\(version) Mobile/\(kernelBuild) Safari/\(safariBuild)"
        } else {
            return "AppleWebKit/\(webkitVersion) (KHTML, like Gecko) Version/\(version) Safari/\(webkitVersion)"
        }
    }
}

public struct FirefoxBrowser: UABrowser {
    public var version: String?
    public var webkitVersion: String = "605.1.15"
    public var kernelBuild: String = "15E148"
    public var browserType: BrowserType { .firefox }

    public init(version: String? = nil) {
        self.version = version
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "137.0"
        switch device {
        case is iOSDevice:
            return "AppleWebKit/\(webkitVersion) (KHTML, like Gecko) FxiOS/\(version) Mobile/\(kernelBuild) Safari/\(webkitVersion)"
        case is MacDevice:
            return "Gecko/20100101 Firefox/\(version)"
        case is LinuxDevice:
            return "Gecko/\(version) Firefox/\(version)"
        case is WindowsDevice:
            return "Gecko/20100101 Firefox/\(version)"
        default:
            return "Gecko/\(version) Firefox/\(version)"
        }
    }
}

public struct ChromeBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .chrome }

    public init(version: String? = nil) {
        self.version = version
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        if device is iOSDevice {
            let version = self.version ?? "135.0.7049.83"
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/\(version) Mobile/15E148 Safari/604.1"
        } else if device is AndroidDevice {
            let version = self.version ?? "135.0.7049.79"
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Mobile Safari/537.36"
        } else {
            let version = self.version ?? "135.0.0.0"
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Safari/537.36"
        }
    }
}

public struct EdgeBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .edge }

    public init(version: String? = nil) {
        self.version = version
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "123.0.0.0"
        return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Safari/537.36 Edg/\(version)"
    }
}

public struct OperaBrowser: UABrowser {
    public var version: String?
    public var browserType: BrowserType { .opera }

    public init(version: String? = nil) {
        self.version = version
    }

    public func userAgentPlatformInfo(for device: UADevice) -> String {
        if device is AndroidDevice {
            let version = self.version ?? "108.0.0.0"
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Mobile Safari/537.36 OPR/\(version)"
        } else if device is iOSDevice {
            let version = self.version ?? "108.0.0.0"
            let os = device.osVersion ?? "18.4"
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(os) Mobile/15E148 Safari/604.1 OPT/\(version)"
        } else {
            let version = self.version ?? "108.0.0.0"
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Safari/537.36 OPR/\(version)"
        }
    }
}

