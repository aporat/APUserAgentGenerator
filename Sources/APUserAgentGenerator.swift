import Foundation
import DeviceKit
import UIKit

public final class APUserAgentGenerator {
    public var appName: String
    public var appVersion: String?
    public var platform: String?
    public var platformArchitecture: String?
    public var platformVersion: String?

    private var extraParts: [String] = []

    public init() {
        self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
        self.appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        self.platform = Device.current.systemName
        self.platformArchitecture = Device.identifier
        self.platformVersion = Device.current.systemVersion
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

        userAgentParts.append(contentsOf: extraParts)

        var result = appName
        if let version = appVersion {
            result += " \(version)"
        }

        return result + " (" + userAgentParts.joined(separator: "; ") + ")"
    }
}
