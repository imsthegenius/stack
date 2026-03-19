import Foundation

enum ContentFilter {
    /// Returns true if the text is acceptable for submission.
    static func isAcceptable(_ text: String) -> Bool {
        let lower = text.lowercased()
        for word in blockedWords {
            // Match whole words only using word boundary check
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lower.startIndex..., in: lower)
                if regex.firstMatch(in: lower, range: range) != nil {
                    return false
                }
            }
        }
        return true
    }

    private static let blockedWords: [String] = [
        // Slurs and hate speech
        "nigger", "nigga", "faggot", "fag", "retard", "retarded",
        "tranny", "kike", "spic", "chink", "wetback", "gook",
        "cunt", "dyke", "raghead", "towelhead",
        // Explicit sexual
        "fuck", "shit", "cock", "dick", "pussy", "penis", "vagina",
        "blowjob", "handjob", "masturbat", "orgasm", "porn",
        "hentai", "nude", "naked",
        // Violence and self-harm
        "kill yourself", "kys", "kill myself",
        "suicide", "hang yourself",
        // Spam patterns
        "http://", "https://", "www.", ".com/",
        "buy now", "click here", "free money", "crypto",
        "onlyfans", "telegram", "whatsapp"
    ]
}
