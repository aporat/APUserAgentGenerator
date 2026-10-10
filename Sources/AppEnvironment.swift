import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

/// The values an ``AppUserAgent`` auto-detects.
///
/// ``current`` reads `Bundle.main`, `ProcessInfo` and `uname`/`sysctl` — no
/// UIKit, no main actor — so it can be used from any isolation domain and on
/// Linux. Construct one yourself to make app User-Agents deterministic in tests.
public struct AppEnvironment: Sendable, Hashable {
    /// `CFBundleName`, falling back to the executable / process name.
    public var appName: String?
    /// `CFBundleShortVersionString`.
    public var appVersion: String?
    /// `CFBundleVersion`.
    public var buildNumber: String?
    /// The OS name: `iOS`, `macOS`, `tvOS`, `watchOS`, `visionOS` or `Linux`.
    public var systemName: String?
    /// The OS version, e.g. `27.0.1` (from `ProcessInfo.operatingSystemVersion`).
    public var systemVersion: String?
    /// The hardware model identifier, e.g. `iPhone17,1` or `Mac15,3`. In the
    /// simulator this is the simulated model; on Linux it is the machine
    /// architecture (`x86_64`, `aarch64`) because there is no model identifier.
    public var deviceModel: String?

    public init(
        appName: String? = nil,
        appVersion: String? = nil,
        buildNumber: String? = nil,
        systemName: String? = nil,
        systemVersion: String? = nil,
        deviceModel: String? = nil
    ) {
        self.appName = appName
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.deviceModel = deviceModel
    }

    /// The running app and device.
    public static var current: AppEnvironment {
        let bundle = Bundle.main
        let info = ProcessInfo.processInfo
        func string(_ key: String) -> String? {
            bundle.object(forInfoDictionaryKey: key) as? String
        }
        return AppEnvironment(
            appName: string("CFBundleName") ?? string("CFBundleExecutable") ?? info.processName,
            appVersion: string("CFBundleShortVersionString"),
            buildNumber: string("CFBundleVersion"),
            systemName: Self.currentSystemName,
            systemVersion: info.operatingSystemVersion.marketingVersion,
            deviceModel: Self.currentDeviceModel
        )
    }

    // MARK: - Detection

    private static var currentSystemName: String? {
        #if targetEnvironment(macCatalyst)
        return "macOS"
        #elseif os(iOS)
        return "iOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(Linux)
        return "Linux"
        #elseif os(Windows)
        return "Windows"
        #else
        return nil
        #endif
    }

    private static var currentDeviceModel: String? {
        #if targetEnvironment(simulator)
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"], !simulated.isEmpty {
            return simulated
        }
        #endif
        #if os(macOS) || targetEnvironment(macCatalyst)
        if let model = sysctlString("hw.model") {
            return model
        }
        #endif
        return unameMachine
    }

    #if canImport(Darwin)
    private static func sysctlString(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        guard let value = String(bytes: bytes, encoding: .utf8), !value.isEmpty else { return nil }
        return value
    }
    #endif

    private static var unameMachine: String? {
        #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
        var system = utsname()
        guard uname(&system) == 0 else { return nil }
        let machine = withUnsafeBytes(of: &system.machine) { raw in
            String(bytes: raw.prefix { $0 != 0 }, encoding: .utf8)
        }
        guard let machine, !machine.isEmpty else { return nil }
        return machine
        #else
        return nil
        #endif
    }
}
