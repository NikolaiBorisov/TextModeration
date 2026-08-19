import Foundation

/// A rule that reports text matching configurable prohibited words or phrases.
public struct ProfanityRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "profanity"
    
    private let prohibitedTerms: [String]
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a profanity rule with developer-provided prohibited terms.
    ///
    /// The rule does not include a built-in profanity dataset. Apps provide their own
    /// words and phrases according to their language, audience, and community standards.
    ///
    /// - Parameters:
    ///   - prohibitedTerms: Words or phrases that should produce a moderation issue.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        prohibitedTerms: [String],
        severity: ModerationSeverity = .high,
        decision: ModerationDecision = .blocked
    ) {
        self.prohibitedTerms = prohibitedTerms
            .map(Self.normalized)
            .filter { !$0.isEmpty }
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text matches any configured prohibited term.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let normalizedText = Self.normalized(text)
        
        guard prohibitedTerms.contains(where: { normalizedText.contains($0) }) else {
            return nil
        }
        
        return ModerationIssue(
            ruleID: id,
            message: "Text contains a prohibited word or phrase.",
            severity: severity,
            suggestedDecision: decision
        )
    }
    
    private static func normalized(_ text: String) -> String {
        let foldedText = text.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )
        
        let substitutedText = foldedText
            .replacingOccurrences(of: "0", with: "o")
            .replacingOccurrences(of: "1", with: "i")
            .replacingOccurrences(of: "3", with: "e")
            .replacingOccurrences(of: "4", with: "a")
            .replacingOccurrences(of: "5", with: "s")
            .replacingOccurrences(of: "7", with: "t")
            .replacingOccurrences(of: "@", with: "a")
            .replacingOccurrences(of: "$", with: "s")
            .replacingOccurrences(of: "!", with: "i")
        
        let lettersAndNumbers = substitutedText.unicodeScalars.filter { scalar in
            CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar)
        }
        
        return collapseRepeatedCharacters(in: String(String.UnicodeScalarView(lettersAndNumbers)))
    }
    
    private static func collapseRepeatedCharacters(in text: String) -> String {
        var result = ""
        var previousCharacter: Character?
        
        for character in text {
            if character != previousCharacter {
                result.append(character)
                previousCharacter = character
            }
        }
        
        return result
    }
}
