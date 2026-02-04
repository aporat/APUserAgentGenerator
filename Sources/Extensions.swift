extension String {
    func underscoredVersion(limit: Int = 3) -> String {
        let parts = self.split(separator: ".")
        let limitedParts = parts.prefix(limit)
        return limitedParts.joined(separator: "_")
    }
}
