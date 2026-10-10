import Foundation

/// A finished User-Agent header value.
public protocol UserAgent: Sendable, CustomStringConvertible {
    /// The header value, ready for `User-Agent:` or `WKWebView.customUserAgent`.
    var value: String { get }
}

extension UserAgent {
    public var description: String { value }
}
