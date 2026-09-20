import Foundation
#if canImport(DeviceKit)
import DeviceKit
#endif

// MARK: - Protocols

public protocol UADevice: Sendable {
    var osVersion: String? { get }
    var deviceModel: String { get }

    func userAgentSystemInfo(for browser: UABrowser) -> String
}

// MARK: - Concrete Devices

public struct MacDevice: UADevice {
    /// An explicit macOS version override.
    ///
    /// Leave this `nil` for realistic output: no shipping browser reports the
    /// real macOS version. Safari, Chrome and Edge have all pinned it to
    /// 10.15.7 since Safari 15 / Chrome 90, and Firefox reports `10.15`.
    public var osVersion: String?
    public var deviceModel: String = "Macintosh"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        switch browser.browserType {
        case .firefox:
            let version = osVersion?.dottedVersion(limit: 2) ?? UAVersions.Frozen.macOSVersionDotted
            return "Macintosh; Intel Mac OS X \(version); rv:\(browser.version(for: self))"
        default:
            let version = osVersion?.underscoredVersion() ?? UAVersions.Frozen.macOSVersion
            return "Macintosh; Intel Mac OS X \(version)"
        }
    }
}

public struct IOSDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "iPhone"

    public init(osVersion: String? = nil) {
        if let osVersion {
            self.osVersion = osVersion
        } else {
#if os(iOS) && canImport(DeviceKit)
            self.osVersion = Device.current.systemVersion
#else
            self.osVersion = UAVersions.iOS
#endif
        }
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        "iPhone; CPU iPhone OS \(reportedOSVersion(for: browser)) like Mac OS X"
    }

    /// Resolves Apple's OS-version freeze.
    ///
    /// Starting with iOS 26 / Safari 26, WebKit reports a pinned OS token
    /// instead of the real version. That covers every browser rendering with
    /// the system WebKit — Safari, Edge, Firefox and Opera on iOS — but not
    /// Chrome, which assembles its own User-Agent.
    private func reportedOSVersion(for browser: UABrowser) -> String {
        guard browser.usesSystemWebKitUserAgent else {
            return actualOSVersion
        }

        // A Safari version override drives the freeze decision; other browsers
        // inherit whatever Safari the system ships.
        let safariMajor = (browser as? SafariBrowser)
            .flatMap { Int($0.version(for: self).leadingDigits) }
            ?? UAVersions.safariMajor

        guard safariMajor >= UAVersions.Frozen.iOSFreezeIntroducedInSafari else {
            return actualOSVersion
        }
        return UAVersions.Frozen.iOSVersion
    }

    private var actualOSVersion: String {
        (osVersion ?? UAVersions.iOS).underscoredVersion(limit: 2)
    }
}

public struct AndroidDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String

    /// Whether to emit Chromium's reduced platform token (`Android 10; K`)
    /// instead of the real Android version and device model.
    ///
    /// Chrome has sent the reduced token since Chrome 110, and Edge and Opera
    /// followed, so it is what real Chromium traffic looks like. It defaults to
    /// `true` unless you supply a `deviceModel`, on the assumption that naming a
    /// model means you want it in the output.
    ///
    /// Firefox ignores this flag: it freezes the Android version to 10
    /// unconditionally and never reports a model.
    public var usesReducedPlatformToken: Bool

    public init(
        deviceModel: String? = nil,
        osVersion: String? = nil,
        usesReducedPlatformToken: Bool? = nil
    ) {
        self.deviceModel = deviceModel ?? UAVersions.Frozen.androidModel
        self.osVersion = osVersion
        self.usesReducedPlatformToken = usesReducedPlatformToken ?? (deviceModel == nil)
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        switch browser.browserType {
        case .firefox:
            // Firefox for Android has pinned the OS token to 10 since Firefox 122.
            return "Android \(UAVersions.Frozen.androidVersion); Mobile; rv:\(browser.version(for: self))"
        default:
            guard usesReducedPlatformToken else {
                return "Linux; Android \(osVersion ?? UAVersions.android); \(deviceModel)"
            }
            return "Linux; Android \(UAVersions.Frozen.androidVersion); \(UAVersions.Frozen.androidModel)"
        }
    }
}

public struct WindowsDevice: UADevice {
    public var osVersion: String?
    public var deviceModel: String = "WindowsPC"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        // Windows NT 10.0 remains the standard for compatibility, even for Windows 11/12.
        let version = osVersion ?? UAVersions.windowsNT
        switch browser.browserType {
        case .firefox:
            return "Windows NT \(version); Win64; x64; rv:\(browser.version(for: self))"
        default:
            return "Windows NT \(version); Win64; x64"
        }
    }
}

public struct LinuxDevice: UADevice {
    /// Unused. Linux User-Agent strings carry no OS version; the property exists
    /// only to satisfy ``UADevice``.
    public var osVersion: String?
    public var deviceModel: String = "Linux"

    public init(osVersion: String? = nil) {
        self.osVersion = osVersion
    }

    public func userAgentSystemInfo(for browser: UABrowser) -> String {
        switch browser.browserType {
        case .firefox:
            return "X11; Linux x86_64; rv:\(browser.version(for: self))"
        default:
            return "X11; Linux x86_64"
        }
    }
}
