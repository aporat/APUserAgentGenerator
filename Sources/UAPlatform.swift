import Foundation

/// The operating system a ``UADevice`` represents.
///
/// Every formatting decision in the package switches exhaustively over this
/// enum, so adding a case is a compile error everywhere it matters rather than
/// a silent fallthrough to some other platform's output.
public enum UAPlatform: String, CaseIterable, Sendable, Hashable, CustomStringConvertible {
    case iOS
    case macOS
    case android
    case windows
    case linux

    /// The browsers that actually ship on this platform.
    ///
    /// Building a ``BrowserUserAgent`` for any other combination throws
    /// ``UserAgentError/unsupportedCombination(browser:platform:)``.
    public var supportedBrowsers: Set<BrowserType> {
        switch self {
        case .iOS, .macOS:
            return Set(BrowserType.allCases)
        case .android, .windows, .linux:
            // Safari only ships on Apple platforms.
            return [.chrome, .firefox, .edge, .opera]
        }
    }

    /// Whether `browser` ships on this platform.
    public func supports(_ browser: BrowserType) -> Bool {
        supportedBrowsers.contains(browser)
    }

    public var description: String { rawValue }
}
