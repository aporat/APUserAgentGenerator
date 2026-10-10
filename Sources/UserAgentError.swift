import Foundation

/// Why a User-Agent could not be built.
///
/// Browser User-Agents are validated rather than escaped: a real browser never
/// emits a malformed version or an impossible platform, so producing one would
/// defeat the point of the string. App User-Agents escape their input instead,
/// and only fail on an empty product name.
public enum UserAgentError: Error, Equatable, Sendable, CustomStringConvertible {
    /// The browser does not ship on the platform, e.g. Safari on Android.
    case unsupportedCombination(browser: BrowserType, platform: UAPlatform)

    /// A version is not one to four dot-separated non-negative integers
    /// (`"27"`, `"27.0"`, `"156.0.8078.12"`), or has too few components for the
    /// field it is used in.
    case invalidVersion(field: String, value: String)

    /// A device model contains characters that would corrupt the header or
    /// escape the comment it is placed in (`;`, `(`, `)`, `\`, control or
    /// non-ASCII characters), or is empty.
    case invalidDeviceModel(String)

    /// Two versions that a real device can only report together disagree, e.g.
    /// a Safari 26 override on an iOS 17 device. Safari on iOS ships with the
    /// OS, so its major version always matches the iOS major version.
    case inconsistentVersions(String)

    /// The app name of an ``AppUserAgent`` is empty after trimming.
    case emptyAppName

    public var description: String {
        switch self {
        case let .unsupportedCombination(browser, platform):
            return "\(browser) does not ship on \(platform)"
        case let .invalidVersion(field, value):
            return "Invalid \(field) version: \(value.debugDescription)"
        case let .invalidDeviceModel(model):
            return "Invalid device model: \(model.debugDescription)"
        case let .inconsistentVersions(detail):
            return "Inconsistent versions: \(detail)"
        case .emptyAppName:
            return "The app name is empty"
        }
    }
}
