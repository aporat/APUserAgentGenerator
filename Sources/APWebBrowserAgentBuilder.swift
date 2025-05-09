import Foundation

// MARK: - UA Generator

public class APWebBrowserAgentBuilder {
    public var device: UADevice
    public var browser: UABrowser
    
    public init(device: UADevice, browser: UABrowser) {
        self.device = device
        self.browser = browser
    }
    
    public func generate() -> String {
        let systemInfo = device.userAgentSystemInfo(for: browser)
        let platformInfo = browser.userAgentPlatformInfo(for: device)
        
        return "Mozilla/5.0 (\(systemInfo)) \(platformInfo)"
    }
    
    // MARK: - Builder Style
    
    public static func builder() -> Builder {
        return Builder()
    }
    
    public class Builder {
        private var device: UADevice = iOSDevice()
        private var browser: UABrowser = SafariBrowser()
        
        public func withDevice(_ device: UADevice) -> Builder {
            self.device = device
            return self
        }
        
        public func withBrowser(_ browser: UABrowser) -> Builder {
            self.browser = browser
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

// MARK: - String Extension

public extension String {
    func underscoredVersion(limit: Int = 3) -> String {
        let parts = self.split(separator: ".")
        let limitedParts = parts.prefix(limit)
        return limitedParts.joined(separator: "_")
    }
}
