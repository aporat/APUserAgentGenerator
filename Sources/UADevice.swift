import Foundation
import DeviceKit

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
        let version = osVersion ?? "16.0"
        
        switch browser.browserType {
        case .firefox:
            // Refined to use the proper browser.version(for:) function
            let trimmed = version.split(separator: ".").prefix(2).joined(separator: ".")
            let browserVersion = browser.version(for: self)
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
        // Simplified initializer logic
        self.osVersion = osVersion ?? Device.current.systemVersion
    }
    
    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        var reportedOSVersion: String
        
        // This logic correctly handles Safari's privacy feature for its User-Agent.
        // It checks the browser's version to decide if the OS version should be "frozen".
        if let safari = browser as? SafariBrowser {
            let safariVersionString = safari.version(for: self)
            let safariMajorVersion = Int(safariVersionString.split(separator: ".").first ?? "0") ?? 0
            
            // For Safari versions that are un-versioned or >= 26.0 (hypothetical future versioning)
            // Apple freezes the OS version to 18_6 for privacy.
            if safariMajorVersion >= 26 {
                reportedOSVersion = "18_6"
            } else {
                // Updated default to iOS 19
                let version = osVersion ?? "19.1"
                reportedOSVersion = version.underscoredVersion(limit: 2)
            }
        } else {
            // For other browsers like Chrome, Firefox, etc., use the actual OS version.
            let version = osVersion ?? "19.1"
            reportedOSVersion = version.underscoredVersion(limit: 2)
        }
        
        return "iPhone; CPU iPhone OS \(reportedOSVersion) like Mac OS X"
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
        let version = osVersion ?? "16"
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
        // Windows NT 10.0 remains the standard for compatibility, even for Windows 11/12
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
        let version = osVersion ?? "7.0"
        switch browser.browserType {
        case .firefox:
            return "X11; Linux x86_64; rv:\(version)"
        default:
            return "X11; Linux x86_64"
        }
    }
}
