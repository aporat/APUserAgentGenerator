import Foundation

/// A User-Agent for your own app's HTTP traffic, in RFC 9110 product form:
///
/// ```
/// MyApp/1.4.2 (iOS 27.0.1; iPhone17,1; build:812; SDK/3.2)
/// ```
///
/// The product token (`Name/Version`) is percent-encoded the way CFNetwork
/// encodes a bundle name (`My App` → `My%20App`), and every comment part is
/// percent-encoded wherever it could corrupt the header or break out of the
/// comment (`(`, `)`, `\`, `;`, `%`, control and non-ASCII characters).
///
/// Every field is auto-detected from ``AppEnvironment/current`` unless you set
/// it, and every field except the app name can be omitted.
public struct AppUserAgent: UserAgent, Hashable {
    /// The fields that are auto-detected and can be omitted.
    public enum Field: String, CaseIterable, Sendable, Hashable {
        case appVersion
        case buildNumber
        case systemName
        case systemVersion
        case deviceModel
    }

    /// The rendered header value.
    public let value: String

    /// Starts a chainable builder that auto-detects from `environment`.
    public static func builder(environment: AppEnvironment = .current) -> Builder {
        Builder(environment: environment)
    }

    // MARK: - Builder

    /// A chainable, immutable builder.
    public struct Builder: Sendable, Hashable {
        private let environment: AppEnvironment
        private var appName: String?
        private var values: [Field: FieldValue] = [:]
        private var comments: [String] = []

        public init(environment: AppEnvironment = .current) {
            self.environment = environment
        }

        public func appName(_ name: String) -> Builder {
            var copy = self
            copy.appName = name
            return copy
        }

        public func appVersion(_ version: String) -> Builder { setting(.appVersion, version) }
        public func buildNumber(_ build: String) -> Builder { setting(.buildNumber, build) }
        /// The OS name, e.g. `iOS` or `iPadOS`.
        public func systemName(_ name: String) -> Builder { setting(.systemName, name) }
        /// The OS version, e.g. `27.0.1`.
        public func systemVersion(_ version: String) -> Builder { setting(.systemVersion, version) }
        /// The hardware model identifier, e.g. `iPhone17,1`.
        public func deviceModel(_ model: String) -> Builder { setting(.deviceModel, model) }

        /// Leaves `fields` out of the User-Agent entirely, even when they could
        /// be auto-detected.
        public func omitting(_ fields: Field...) -> Builder {
            var copy = self
            for field in fields {
                copy.values[field] = .omitted
            }
            return copy
        }

        /// Appends a free-form comment part, e.g. `SDK/3.2`.
        public func addingComment(_ comment: String) -> Builder {
            var copy = self
            copy.comments.append(comment)
            return copy
        }

        /// Renders the User-Agent.
        ///
        /// - Throws: ``UserAgentError/emptyAppName`` when the app name is empty
        ///   after trimming. Everything else is escaped, never rejected.
        public func build() throws -> AppUserAgent {
            let name = UserAgentEscaping.token(appName ?? environment.appName ?? "")
            guard !name.isEmpty else { throw UserAgentError.emptyAppName }

            var product = name
            if let version = resolve(.appVersion).map(UserAgentEscaping.token), !version.isEmpty {
                product += "/\(version)"
            }

            let system = [resolve(.systemName), resolve(.systemVersion)]
                .compactMap { $0 }
                .map(UserAgentEscaping.comment)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let model = resolve(.deviceModel).map(UserAgentEscaping.comment) ?? ""
            let build = resolve(.buildNumber).map(UserAgentEscaping.comment) ?? ""

            let parts = [system, model, build.isEmpty ? "" : "build:\(build)"]
                + comments.map(UserAgentEscaping.comment)
            let comment = parts.filter { !$0.isEmpty }.joined(separator: "; ")

            return AppUserAgent(value: comment.isEmpty ? product : "\(product) (\(comment))")
        }

        private func setting(_ field: Field, _ value: String) -> Builder {
            var copy = self
            copy.values[field] = .custom(value)
            return copy
        }

        private func resolve(_ field: Field) -> String? {
            switch values[field] ?? .automatic {
            case .omitted:
                return nil
            case let .custom(value):
                return value
            case .automatic:
                switch field {
                case .appVersion: return environment.appVersion
                case .buildNumber: return environment.buildNumber
                case .systemName: return environment.systemName
                case .systemVersion: return environment.systemVersion
                case .deviceModel: return environment.deviceModel
                }
            }
        }
    }
}

/// How a builder resolves one ``AppUserAgent/Field``.
private enum FieldValue: Sendable, Hashable {
    case automatic
    case custom(String)
    case omitted
}
