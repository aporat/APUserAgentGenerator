import Foundation
@preconcurrency import DeviceKit

public final class APAppUserAgentBuilder {
    private let appName: String
    private let buildNumber: String?
    private let appVersion: String?
    private let platform: String?
    private let platformArchitecture: String?
    private let platformVersion: String?
    private let extraParts: [String]
    
    public init(appName: String? = nil, appVersion: String? = nil, buildNumber: String? = nil, platform: String? = nil, platformArchitecture: String? = nil, platformVersion: String? = nil, extraParts: [String] = []) {
        self.appName = appName ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App")
        self.buildNumber = buildNumber ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        self.appVersion = appVersion ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        self.platform = platform ?? Device.current.systemName
        self.platformArchitecture = platformArchitecture ?? Device.identifier
        self.platformVersion = platformVersion ?? Device.current.systemVersion
        self.extraParts = extraParts
    }
    
    public func generate() -> String {
        let optionalParts: [String?] = [
            platform,
            platformArchitecture,
            platformVersion,
            buildNumber
        ]
        
        var finalParts = optionalParts.compactMap { $0 }
        finalParts.append(contentsOf: extraParts)
        
        var result = appName
        if let version = appVersion {
            result += " \(version)"
        }
        
        return result + " (" + finalParts.joined(separator: "; ") + ")"
    }
    
    public static func builder() -> Builder {
        return Builder()
    }
    
    public struct Builder: Sendable {
        private var appName: String?
        private var appVersion: String?
        private var buildNumber: String?
        private var platform: String?
        private var platformArchitecture: String?
        private var platformVersion: String?
        private var extraParts: [String] = []
        
        public func withAppName(_ name: String) -> Builder {
            var newBuilder = self
            newBuilder.appName = name
            return newBuilder
        }
        
        public func withAppVersion(_ version: String) -> Builder {
            var newBuilder = self
            newBuilder.appVersion = version
            return newBuilder
        }
        
        public func withBuildNumber(_ build: String) -> Builder {
            var newBuilder = self
            newBuilder.buildNumber = build
            return newBuilder
        }
        
        public func withPlatform(_ platform: String) -> Builder {
            var newBuilder = self
            newBuilder.platform = platform
            return newBuilder
        }
        
        public func withPlatformArchitecture(_ arch: String) -> Builder {
            var newBuilder = self
            newBuilder.platformArchitecture = arch
            return newBuilder
        }
        
        public func withPlatformVersion(_ version: String) -> Builder {
            var newBuilder = self
            newBuilder.platformVersion = version
            return newBuilder
        }
        
        public func addPart(_ part: String) -> Builder {
            var newBuilder = self
            newBuilder.extraParts.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
            return newBuilder
        }
        
        public func build() -> APAppUserAgentBuilder {
            return APAppUserAgentBuilder(
                appName: appName,
                appVersion: appVersion,
                buildNumber: buildNumber,
                platform: platform,
                platformArchitecture: platformArchitecture,
                platformVersion: platformVersion,
                extraParts: extraParts
            )
        }
        
        public func generate() -> String {
            return build().generate()
        }
    }
}
