import Foundation

// MARK: - Protocols

public protocol UADevice {
    var osVersion: String? { get }
    var deviceModel: String { get }
    func userAgentSystemInfo(for browser: BrowserType) -> String
}

public protocol UABrowser {
    var version: String? { get }
    func userAgentPlatformInfo(for device: UADevice) -> String
    var browserType: BrowserType { get }
}

// MARK: - Enums

public enum BrowserType: CaseIterable {
    case safari, chrome, firefox, edge, opera
}

public enum PlatformType: CaseIterable {
    case iOS, macOS, android, windows, linux
}

// MARK: - Concrete Devices

public struct MacDevice: UADevice {
    public var osVersion: String? = nil
    public var deviceModel: String = "Macintosh"
    
    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }
    
    public func userAgentSystemInfo(for browser: BrowserType) -> String {
        let version = osVersion ?? "14.4"
        switch browser {
        case .firefox:
            return "Macintosh; Intel Mac OS X \(version)"
        default:
            let underscored = version.replacingOccurrences(of: ".", with: "_")
            return "Macintosh; Intel Mac OS X \(underscored)"
        }
    }
}

public struct IPhoneDevice: UADevice {
    public var osVersion: String? = nil
    public var deviceModel: String = "iPhone"
    
    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }
    
    public func userAgentSystemInfo(for browser: BrowserType) -> String {
        let version = osVersion ?? "18.4"
        let underscored = version.replacingOccurrences(of: ".", with: "_")
        return "iPhone; CPU iPhone OS \(underscored) like Mac OS X"
    }
}

public struct AndroidDevice: UADevice {
    public var osVersion: String? = nil
    public var deviceModel: String
    
    public init(osVersion: String? = nil, deviceModel: String) {
        self.osVersion = osVersion
        self.deviceModel = deviceModel
    }
    
    public func userAgentSystemInfo(for browser: BrowserType) -> String {
        let version = osVersion ?? "14"
        return "Linux; Android \(version); \(deviceModel)"
    }
}

public struct WindowsDevice: UADevice {
    public var osVersion: String? = nil
    public var deviceModel: String = "WindowsPC"
    
    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }
    
    public func userAgentSystemInfo(for browser: BrowserType) -> String {
        let version = osVersion ?? "10.0"
        return "Windows NT \(version); Win64; x64"
    }
}

public struct LinuxDevice: UADevice {
    public var osVersion: String? = nil
    public var deviceModel: String = "Linux"
    
    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }
    
    public func userAgentSystemInfo(for browser: BrowserType) -> String {
        let version = osVersion ?? "6.0"
        switch browser {
        case .firefox:
            return "X11; Linux x86_64; rv:\(version)"
        default:
            return "X11; Linux x86_64"
        }
    }
}

// MARK: - Concrete Browsers

public struct SafariBrowser: UABrowser {
    public var version: String? = nil
    public var webkitVersion: String = "605.1.15"
    public var safariBuild: String = "604.1"
    public var kernelBuild: String = "15E148"
    public var browserType: BrowserType { .safari }
    
    public init(version: String? = nil) {
        self.version = version
    }
    
    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "18.4"
        if device is IPhoneDevice {
            return "AppleWebKit/\(webkitVersion) (KHTML, like Gecko) Version/\(version) Mobile/\(kernelBuild) Safari/\(safariBuild)"
        } else {
            return "AppleWebKit/\(webkitVersion) (KHTML, like Gecko) Version/\(version) Safari/\(webkitVersion)"
        }
    }
}

public struct FirefoxBrowser: UABrowser {
    public var version: String? = nil
    public var webkitVersion: String = "605.1.15"
    public var kernelBuild: String = "15E148"
    public var browserType: BrowserType { .firefox }
    
    public init(version: String? = nil) {
        self.version = version
    }
    
    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "137.0"
        switch device {
        case is IPhoneDevice:
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
    public var version: String? = nil
    public var browserType: BrowserType { .chrome }
    
    public init(version: String? = nil) {
        self.version = version
    }
    
    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "123.0.0.0"
        if device is AndroidDevice {
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Mobile Safari/537.36"
        } else if device is IPhoneDevice {
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/\(version) Mobile/15E148 Safari/604.1"
        } else {
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Safari/537.36"
        }
    }
}

public struct EdgeBrowser: UABrowser {
    public var version: String? = nil
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
    public var version: String? = nil
    public var browserType: BrowserType { .opera }
    
    public init(version: String? = nil) {
        self.version = version
    }
    
    public func userAgentPlatformInfo(for device: UADevice) -> String {
        let version = self.version ?? "108.0.0.0"
        if device is AndroidDevice {
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Mobile Safari/537.36 OPR/\(version)"
        } else if device is IPhoneDevice {
            let os = device.osVersion ?? "18.4"
            return "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(os) Mobile/15E148 Safari/604.1 OPT/\(version)"
        } else {
            return "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(version) Safari/537.36 OPR/\(version)"
        }
    }
}

// MARK: - UA Generator

public class APWebBrowserAgentBuilder {
    public var device: UADevice
    public var browser: UABrowser
    
    public init(device: UADevice, browser: UABrowser) {
        self.device = device
        self.browser = browser
    }
    
    public func generate() -> String {
        let systemInfo = device.userAgentSystemInfo(for: browser.browserType)
        let platformInfo = browser.userAgentPlatformInfo(for: device)
        return "Mozilla/5.0 (\(systemInfo)) \(platformInfo)"
    }
    
    public static func random() -> String {
        return builder().randomize().generate()
    }
    
    // MARK: - Builder Style
    
    public static func builder() -> Builder {
        return Builder()
    }
    
    public class Builder {
        private var device: UADevice = IPhoneDevice()
        private var browser: UABrowser = SafariBrowser()
        
        public func withDevice(_ device: UADevice) -> Builder {
            self.device = device
            return self
        }
        
        public func withBrowser(_ browser: UABrowser) -> Builder {
            self.browser = browser
            return self
        }
        
        public func randomize() -> Builder {
            let platform = PlatformType.allCases.randomElement()!
            let browserType = BrowserType.allCases.randomElement()!
            let osVersion = "\(Int.random(in: 14...18)).\(Int.random(in: 0...5))"
            let browserVersion = "\(Int.random(in: 90...140)).0.0.0"
            let deviceModel = ["Pixel 5", "Pixel 7", "Pixel 8"].randomElement()!
            
            self.device = {
                switch platform {
                case .iOS: return IPhoneDevice(osVersion: osVersion)
                case .macOS: return MacDevice(osVersion: osVersion)
                case .android: return AndroidDevice(osVersion: osVersion, deviceModel: deviceModel)
                case .windows: return WindowsDevice(osVersion: osVersion)
                case .linux: return LinuxDevice(osVersion: osVersion)
                }
            }()
            
            self.browser = {
                switch browserType {
                case .safari: return SafariBrowser(version: osVersion)
                case .chrome: return ChromeBrowser(version: browserVersion)
                case .firefox: return FirefoxBrowser(version: browserVersion)
                case .edge: return EdgeBrowser(version: browserVersion)
                case .opera: return OperaBrowser(version: browserVersion)
                }
            }()
            
            return self
        }
        
        public func build() -> APWebBrowserAgentBuilder {
            return APWebBrowserAgentBuilder(device: device, browser: browser)
        }
        
        public func generate() -> String {
            return build().generate()
        }
    }
}
