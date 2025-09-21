import Foundation

// MARK: - Protocols

public protocol UADevice: Sendable {
    var osVersion: String? { get }
    var deviceModel: String { get }
    func userAgentSystemInfo(for browser: UABrowser) -> String
}

// MARK: - Concrete Devices

public struct MacDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "Macintosh"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        let version = osVersion ?? "10.15.7"
        switch browser.browserType {
        case .firefox:
            let trimmed = version.split(separator: ".").prefix(2).joined(separator: ".")
            let browserVersion = browser.version ?? "137.0"
            return "Macintosh; Intel Mac OS X \(trimmed); rv:\(browserVersion)"
        default:
            return "Macintosh; Intel Mac OS X \(version.underscoredVersion())"
        }
    }
}

public struct iOSDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "iPhone"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        let version = osVersion ?? "18.4"
        return "iPhone; CPU iPhone OS \(version.underscoredVersion(limit: 2)) like Mac OS X"
    }
}

public struct AndroidDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String

    public init(osVersion: String? = nil, deviceModel: String) {
        self.osVersion = osVersion
        self.deviceModel = deviceModel
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        let version = osVersion ?? "14"
        return "Linux; Android \(version); \(deviceModel)"
    }
}

public struct WindowsDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "WindowsPC"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        let version = osVersion ?? "10.0"
        return "Windows NT \(version); Win64; x64"
    }
}

public struct LinuxDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "Linux"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        let version = osVersion ?? "6.0"
        switch browser.browserType {
        case .firefox:
            return "X11; Linux x86_64; rv:\(version)"
        default:
            return "X11; Linux x86_64"
        }
    }
}

