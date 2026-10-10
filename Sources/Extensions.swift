import Foundation

// MARK: - Versions

/// A validated, purely numeric version such as `27.0.1` or `156.0.8078.12`.
struct NumericVersion: Equatable, Sendable {
    let components: [Int]

    /// Parses one to four dot-separated runs of ASCII digits. Anything else —
    /// suffixes like `-beta`, whitespace, empty components, CR/LF — is rejected.
    init?(_ string: String, maxComponents: Int = 4) {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...maxComponents).contains(parts.count) else { return nil }

        var components: [Int] = []
        for part in parts {
            guard !part.isEmpty,
                  part.count <= 9,
                  part.utf8.allSatisfy({ (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0) }),
                  let value = Int(part)
            else { return nil }
            components.append(value)
        }
        self.components = components
    }

    var major: Int { components[0] }
    var minor: Int { components.count > 1 ? components[1] : 0 }

    /// Joins the components with `separator`, padding with zeros up to
    /// `minimum` and truncating to `maximum`.
    func formatted(separator: String = ".", minimum: Int = 1, maximum: Int = 4) -> String {
        var padded = Array(components.prefix(maximum))
        while padded.count < minimum {
            padded.append(0)
        }
        return padded.map(String.init).joined(separator: separator)
    }

    /// `"<major>.0.0.0"`, the shape Chromium's UA reduction gives every token.
    var reduced: String { "\(major).0.0.0" }

    /// `"<major>.0"`.
    var majorDotZero: String { "\(major).0" }

    /// `"<major>.<minor>"`.
    var majorMinor: String { "\(major).\(minor)" }
}

// MARK: - Escaping (app User-Agents)

enum UserAgentEscaping {
    /// RFC 9110 `tchar`, minus `%` (which we use as the escape character).
    private static let tokenCharacters: Set<UInt8> = {
        var set = Set<UInt8>()
        set.formUnion(UInt8(ascii: "0")...UInt8(ascii: "9"))
        set.formUnion(UInt8(ascii: "a")...UInt8(ascii: "z"))
        set.formUnion(UInt8(ascii: "A")...UInt8(ascii: "Z"))
        for character in "!#$&'*+-.^_`|~".utf8 {
            set.insert(character)
        }
        return set
    }()

    /// RFC 9110 `ctext` (printable ASCII and space, minus `(`, `)` and `\`),
    /// minus `;` (our part separator) and `%` (the escape character).
    private static let commentCharacters: Set<UInt8> = {
        var set = Set<UInt8>(0x20...0x7E)
        for character in "()\\;%".utf8 {
            set.remove(character)
        }
        return set
    }()

    /// Percent-encodes everything that is not a token character, the way
    /// CFNetwork encodes a bundle name in its default User-Agent
    /// (`My App` → `My%20App`).
    static func token(_ value: String) -> String {
        percentEncode(trimmed(value), allowed: tokenCharacters)
    }

    /// Percent-encodes everything that could escape or corrupt a comment:
    /// parentheses, backslash, `;`, `%`, control and non-ASCII characters.
    static func comment(_ value: String) -> String {
        percentEncode(trimmed(value), allowed: commentCharacters)
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines.union(.controlCharacters))
    }

    private static func percentEncode(_ value: String, allowed: Set<UInt8>) -> String {
        var result = ""
        for byte in value.utf8 {
            if allowed.contains(byte) {
                result.append(Character(UnicodeScalar(byte)))
            } else {
                result += String(format: "%%%02X", byte)
            }
        }
        return result
    }
}

// MARK: - Validation (browser User-Agents)

enum UserAgentValidation {
    /// A device model may contain printable ASCII except the characters that
    /// would break out of the `( … )` comment or the `;`-separated list.
    static func isValidDeviceModel(_ model: String) -> Bool {
        guard !model.isEmpty, model == model.trimmingCharacters(in: .whitespaces) else { return false }
        return model.utf8.allSatisfy { byte in
            (0x20...0x7E).contains(byte) && !"();\\".utf8.contains(byte)
        }
    }
}
