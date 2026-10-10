import Foundation

// MARK: - Browser kinds

/// The browsers the package can impersonate.
public enum BrowserType: String, CaseIterable, Sendable, Hashable, CustomStringConvertible {
    case safari, chrome, firefox, edge, opera

    /// A browser of this kind using the package's default versions.
    public var browser: any UABrowser {
        switch self {
        case .safari: SafariBrowser()
        case .chrome: ChromeBrowser()
        case .firefox: FirefoxBrowser()
        case .edge: EdgeBrowser()
        case .opera: OperaBrowser()
        }
    }

    public var description: String { rawValue }
}

// MARK: - Protocol

/// A browser to impersonate.
///
/// A browser is just a kind plus an optional version override; all formatting
/// lives in ``BrowserUserAgent``, which switches exhaustively over
/// ``BrowserType`` and ``UAPlatform``. You rarely need your own conformer — the
/// five structs below cover every kind.
public protocol UABrowser: Sendable {
    /// Which browser this is.
    var kind: BrowserType { get }

    /// An explicit version override, unreduced (e.g. `"156.0.8078.12"`). When
    /// `nil`, the platform default from ``UAVersions`` is used. The formatter
    /// reduces it exactly like the real browser would.
    var version: String? { get }
}

// MARK: - Concrete browsers

/// Safari. On iOS the version defaults to the device's `<major>.<minor>` iOS
/// version (Safari ships with the OS); on macOS to ``UAVersions/safariMacOS``.
public struct SafariBrowser: UABrowser, Hashable {
    public var version: String?
    public var kind: BrowserType { .safari }

    public init(version: String? = nil) {
        self.version = version
    }
}

/// Chrome. `Chrome/` is reduced to `<major>.0.0.0` on desktop and Android;
/// `CriOS/` on iOS keeps the full version.
public struct ChromeBrowser: UABrowser, Hashable {
    public var version: String?
    public var kind: BrowserType { .chrome }

    public init(version: String? = nil) {
        self.version = version
    }
}

/// Firefox. `Firefox/` and `rv:` are reported as `<major>.0`; `FxiOS/` on iOS
/// is sent verbatim.
public struct FirefoxBrowser: UABrowser, Hashable {
    public var version: String?
    public var kind: BrowserType { .firefox }

    public init(version: String? = nil) {
        self.version = version
    }
}

/// Microsoft Edge. `Edg/` and `EdgA/` are reduced to `<major>.0.0.0` and the
/// embedded `Chrome/` token always carries the same major; `EdgiOS/` is
/// sent verbatim.
public struct EdgeBrowser: UABrowser, Hashable {
    public var version: String?
    public var kind: BrowserType { .edge }

    public init(version: String? = nil) {
        self.version = version
    }
}

/// Opera. Desktop `OPR/` is reduced to `<major>.0.0.0`; Android `OPR/` and
/// iOS `OPT/` are sent verbatim.
public struct OperaBrowser: UABrowser, Hashable {
    public var version: String?

    /// The Chromium version Opera embeds in its `Chrome/` token (desktop and
    /// Android). When `nil` it is derived from the Opera major using
    /// ``UAVersions/operaChromiumOffset`` / ``UAVersions/operaAndroidChromiumOffset``,
    /// so overriding only ``version`` keeps the two tokens consistent.
    public var chromiumVersion: String?

    public var kind: BrowserType { .opera }

    public init(version: String? = nil, chromiumVersion: String? = nil) {
        self.version = version
        self.chromiumVersion = chromiumVersion
    }
}
