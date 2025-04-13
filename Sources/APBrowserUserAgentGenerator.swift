import Foundation
import UIKit

public enum BrowserType {
    case safari
    case chrome
}

public enum PlatformType {
    case iOS
    case macOS
    case android
    case windows
}

public final class APBrowserUserAgentGenerator {
    public var browser: BrowserType
    public var platform: PlatformType

    public var browserVersion: String?
    public var osVersion: String?
    public var deviceModel: String?

    public init(browser: BrowserType? = nil, platform: PlatformType? = nil) {
        #if os(iOS)
        self.platform = platform ?? .iOS
        self.browser = browser ?? .safari
        #elseif os(macOS)
        self.platform = platform ?? .macOS
        self.browser = browser ?? .chrome
        #else
        self.platform = platform ?? .windows
        self.browser = browser ?? .chrome
        #endif

        self.osVersion = getSystemVersion()
        self.deviceModel = getDeviceModel()
    }

    public func generate() -> String {
        let osVer = osVersion ?? defaultOSVersion()
        let browserVer = browserVersion ?? defaultBrowserVersion()
        let model = deviceModel ?? defaultDeviceModel()

        switch (platform, browser) {
        case (.iOS, .safari):
            return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVer.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(browserVer) Mobile/15E148 Safari/604.1"
        case (.macOS, .safari):
            return "Mozilla/5.0 (Macintosh; Intel Mac OS X \(osVer.replacingOccurrences(of: ".", with: "_"))) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(browserVer) Safari/605.1.15"
        case (.android, .chrome):
            return "Mozilla/5.0 (Linux; Android \(osVer); \(model)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(browserVer) Mobile Safari/537.36"
        case (.windows, .chrome):
            return "Mozilla/5.0 (Windows NT \(osVer); Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(browserVer) Safari/537.36"
        case (.macOS, .chrome):
            return "Mozilla/5.0 (Macintosh; Intel Mac OS X \(osVer.replacingOccurrences(of: ".", with: "_"))) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(browserVer) Safari/537.36"
        default:
            return "Mozilla/5.0 (Unknown Platform)"
        }
    }

    private func getSystemVersion() -> String {
        let version = ProcessInfo().operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion)"
    }

    private func getDeviceModel() -> String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        return "Macintosh"
        #else
        return ""
        #endif
    }

    private func defaultBrowserVersion() -> String {
        switch browser {
            case .safari: return safariVersion
            case .chrome: return "123.0.0.0"
        }
    }

    private func defaultOSVersion() -> String {
        switch platform {
        case .iOS:
            return "17.4"
        case .macOS:
            return "14.4"
        case .android:
            return "14"
        case .windows:
            return "10.0"
        }
    }

    private func defaultDeviceModel() -> String {
        switch platform {
        case .android:
            return "Pixel 7"
        default:
            return ""
        }
    }
    
    private var safariVersion: String {
        let os = ProcessInfo().operatingSystemVersion

        switch os.majorVersion {
        case 12: return "12.1.2"
        case 13: return "13.1.2"
        case 14: return "14.1.2"
        case 15: return "15.6"
        case 16: return "16.6"
        case 17: return "17.4"
        case 18:
            return "\(os.majorVersion).\(os.minorVersion)"
        default:
            return "\(os.majorVersion).0"
        }
    }
}
