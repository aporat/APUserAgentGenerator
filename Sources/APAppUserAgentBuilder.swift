import Foundation
import DeviceKit

public final class APAppUserAgentBuilder {
    private var appName: String
    private var buildNumber: String?
    private var appVersion: String?
    private var platform: String?
    private var platformArchitecture: String?
    private var platformVersion: String?
    private var extraParts: [String] = []
    
    public init(appName: String? = nil, appVersion: String? = nil, buildNumber: String? = nil, platform: String? = nil, platformArchitecture: String? = nil, platformVersion: String? = nil) {
        self.appName = appName ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App")
        self.buildNumber = buildNumber ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        self.appVersion = appVersion ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        self.platform = platform ?? Device.current.systemName
        self.platformArchitecture = platformArchitecture ?? Device.identifier
        self.platformVersion = platformVersion ?? Device.current.systemVersion
    }
    
    public func addPart(_ part: String) {
        extraParts.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func generate() -> String {
        var userAgentParts: [String] = []
        
        if let platform = platform {
            userAgentParts.append(platform)
        }
        
        if let platformArchitecture = platformArchitecture {
            userAgentParts.append(platformArchitecture)
        }
        
        if let platformVersion = platformVersion {
            userAgentParts.append(platformVersion)
        }
        
        if let buildNumber = buildNumber {
            userAgentParts.append(buildNumber)
        }
        
        userAgentParts.append(contentsOf: extraParts)
        
        var result = appName
        if let version = appVersion {
            result += " \(version)"
        }
        
        return result + " (" + userAgentParts.joined(separator: "; ") + ")"
    }
    
    public static func builder() -> APAppUserAgentBuilder.Builder {
        return Builder()
    }
    
    public class Builder {
        private var appName: String?
        private var appVersion: String?
        private var platform: String?
        private var platformArchitecture: String?
        private var platformVersion: String?
        private var extraParts: [String] = []
        
        public func withAppName(_ name: String) -> Builder {
            self.appName = name
            return self
        }
        
        public func withAppVersion(_ version: String) -> Builder {
            self.appVersion = version
            return self
        }
        
        public func withPlatform(_ platform: String) -> Builder {
            self.platform = platform
            return self
        }
        
        public func withPlatformArchitecture(_ arch: String) -> Builder {
            self.platformArchitecture = arch
            return self
        }
        
        public func withPlatformVersion(_ version: String) -> Builder {
            self.platformVersion = version
            return self
        }
        
        public func addPart(_ part: String) -> Builder {
            self.extraParts.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
            return self
        }
        
        public func build() -> APAppUserAgentBuilder {
            let generator = APAppUserAgentBuilder(
                appName: appName,
                appVersion: appVersion,
                platform: platform,
                platformArchitecture: platformArchitecture,
                platformVersion: platformVersion
            )
            extraParts.forEach { generator.addPart($0) }
            return generator
        }
        
        public func generate() -> String {
            return build().generate()
        }
    }
}
