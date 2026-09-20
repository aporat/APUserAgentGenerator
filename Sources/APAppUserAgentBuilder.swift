#if canImport(UIKit)
@preconcurrency import DeviceKit
import Foundation
import UIKit

public final class APAppUserAgentBuilder: Sendable {
    private let appName: String
    private let buildNumber: String?
    private let appVersion: String?
    private let platform: String?
    private let platformArchitecture: String?
    private let platformVersion: String?
    private let extraParts: [String]

    @MainActor
    public init(
        appName: String? = nil,
        appVersion: String? = nil,
        buildNumber: String? = nil,
        platform: String? = nil,
        platformArchitecture: String? = nil,
        platformVersion: String? = nil,
        extraParts: [String] = []
    ) {
        let resolvedName = appName ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        // Every field is sanitized here rather than in `Builder`, so values
        // passed straight to this initializer cannot inject header separators.
        self.appName = Self.sanitized(resolvedName) ?? "App"
        self.buildNumber = Self.sanitized(buildNumber ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        self.appVersion = Self.sanitized(appVersion ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        self.platform = Self.sanitized(platform ?? Device.current.systemName)
        self.platformArchitecture = Self.sanitized(platformArchitecture ?? Device.identifier)
        self.platformVersion = Self.sanitized(platformVersion ?? Device.current.systemVersion)
        self.extraParts = extraParts.compactMap(Self.sanitized)
    }

    private static func sanitized(_ value: String?) -> String? {
        guard let sanitized = value?.sanitizedUserAgentToken(), !sanitized.isEmpty else { return nil }
        return sanitized
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
        if let appVersion {
            result += " \(appVersion)"
        }

        guard !finalParts.isEmpty else { return result }
        return result + " (" + finalParts.joined(separator: "; ") + ")"
    }

    public static func builder() -> Builder {
        Builder()
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
            let sanitized = part.sanitizedUserAgentToken()
            guard !sanitized.isEmpty else { return self }
            var newBuilder = self
            newBuilder.extraParts.append(sanitized)
            return newBuilder
        }

        @MainActor
        public func build() -> APAppUserAgentBuilder {
            APAppUserAgentBuilder(
                appName: appName,
                appVersion: appVersion,
                buildNumber: buildNumber,
                platform: platform,
                platformArchitecture: platformArchitecture,
                platformVersion: platformVersion,
                extraParts: extraParts
            )
        }

        @MainActor
        public func generate() -> String {
            build().generate()
        }
    }
}
#endif
