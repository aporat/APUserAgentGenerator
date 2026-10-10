import Foundation

// MARK: - Protocol

/// A device to impersonate.
///
/// Formatting switches exhaustively over ``platform``; the other two members
/// carry the only per-device data any browser actually reports.
public protocol UADevice: Sendable {
    /// The operating system this device runs.
    var platform: UAPlatform { get }

    /// The OS version reported where browsers still report one (iOS, and
    /// Android when a model is named). `nil` for platforms whose token is frozen.
    var osVersion: String? { get }

    /// A hardware model reported in the platform token. Only Android uses it.
    var model: String? { get }
}

extension UADevice {
    public var osVersion: String? { nil }
    public var model: String? { nil }
}

// MARK: - Concrete devices

/// An iPhone.
///
/// `IOSDevice()` is deterministic: it reports ``UAVersions/iOS`` everywhere,
/// including on a real iPhone, so the same code yields the same string in
/// tests, on a server and on device. Use ``current`` to report the running
/// device's iOS version instead.
public struct IOSDevice: UADevice, Hashable {
    public var platform: UAPlatform { .iOS }

    /// The iOS version, e.g. `"27.0.1"`. Validated when the User-Agent is built.
    public var osVersion: String?

    public init(osVersion: String = UAVersions.iOS) {
        self.osVersion = osVersion
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// The iPhone this code is running on, with its real iOS version.
    ///
    /// Reads `ProcessInfo`, so it is safe to call from any isolation domain.
    public static var current: IOSDevice {
        IOSDevice(osVersion: ProcessInfo.processInfo.operatingSystemVersion.marketingVersion)
    }
    #endif
}

/// A Mac. Every browser reports a frozen macOS version (`10_15_7` / `10.15`),
/// so there is nothing to configure.
public struct MacDevice: UADevice, Hashable {
    public var platform: UAPlatform { .macOS }

    public init() {}
}

/// An Android phone.
///
/// Without a ``model`` the device reports Chromium's reduced platform token
/// (`Linux; Android 10; K`), which is what Chrome, Edge and Opera have sent
/// since Chrome 110 — and ``osVersion`` is ignored, because the real version
/// is never sent. Naming a model opts into the full
/// `Linux; Android <osVersion>; <model>` token (WebView-style).
///
/// Firefox ignores both: it always reports `Android 10; Mobile`.
public struct AndroidDevice: UADevice, Hashable {
    public var platform: UAPlatform { .android }

    /// The hardware model, e.g. `"Pixel 10 Pro"`. `nil` for the reduced token.
    public var model: String?

    /// The Android version reported alongside ``model``. Defaults to
    /// ``UAVersions/android``.
    public var osVersion: String?

    public init(model: String? = nil, osVersion: String? = nil) {
        self.model = model
        self.osVersion = osVersion
    }
}

/// A Windows PC. Every browser reports `Windows NT 10.0; Win64; x64`.
public struct WindowsDevice: UADevice, Hashable {
    public var platform: UAPlatform { .windows }

    public init() {}
}

/// A desktop Linux machine. Every browser reports `X11; Linux x86_64`.
public struct LinuxDevice: UADevice, Hashable {
    public var platform: UAPlatform { .linux }

    public init() {}
}

// MARK: - Helpers

extension OperatingSystemVersion {
    /// `"27.0"` / `"27.0.1"` — the same shape as `UIDevice.systemVersion`.
    var marketingVersion: String {
        patchVersion > 0
            ? "\(majorVersion).\(minorVersion).\(patchVersion)"
            : "\(majorVersion).\(minorVersion)"
    }
}
