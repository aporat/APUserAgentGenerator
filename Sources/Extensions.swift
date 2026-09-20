import Foundation

extension String {
    /// `"18.7.8"` → `"18_7_8"`, keeping at most `limit` components.
    func underscoredVersion(limit: Int = 3) -> String {
        joinedVersion(separator: "_", limit: limit)
    }

    /// `"10.15.7"` → `"10.15"`, keeping at most `limit` components.
    func dottedVersion(limit: Int = 3) -> String {
        joinedVersion(separator: ".", limit: limit)
    }

    private func joinedVersion(separator: String, limit: Int) -> String {
        split(separator: ".").prefix(limit).joined(separator: separator)
    }

    /// The leading run of digits, e.g. `"27"` for both `"27.0"` and `"27-beta"`.
    /// Empty when the string does not start with a digit.
    var leadingDigits: String {
        String(prefix(while: \.isNumber))
    }

    /// The first `.`-separated component, when it starts with a digit.
    var majorVersionComponent: String? {
        let major = split(separator: ".").first.map(String.init)?.leadingDigits
        return (major?.isEmpty == false) ? major : nil
    }

    /// Strips the characters that would corrupt a User-Agent header.
    ///
    /// Control characters — CR and LF above all — are removed outright, since
    /// leaving them in an app-supplied token would allow header injection.
    /// Parentheses are removed and `;` becomes `,` so a token cannot escape the
    /// comment section it is placed in.
    func sanitizedUserAgentToken() -> String {
        let cleaned = unicodeScalars
            .filter { !CharacterSet.controlCharacters.contains($0) }
            .map(Character.init)
            .reduce(into: "") { partialResult, character in
                switch character {
                case ";": partialResult.append(",")
                case "(", ")": break
                default: partialResult.append(character)
                }
            }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
