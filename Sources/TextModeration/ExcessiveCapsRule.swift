import Foundation

/// A rule that reports text containing an excessive ratio of uppercase letters.
public struct ExcessiveCapsRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "excessive_caps"
    
    private let minimumLetterCount: Int
    private let uppercaseRatioThreshold: Double
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates an excessive caps rule.
    ///
    /// - Parameters:
    ///   - minimumLetterCount: The minimum number of letters required before the rule can match.
    ///   - uppercaseRatioThreshold: The uppercase letter ratio required for the rule to match.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        minimumLetterCount: Int = 8,
        uppercaseRatioThreshold: Double = 0.7,
        severity: ModerationSeverity = .low,
        decision: ModerationDecision = .flagged
    ) {
        self.minimumLetterCount = minimumLetterCount
        self.uppercaseRatioThreshold = uppercaseRatioThreshold
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains an excessive ratio of uppercase letters.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        
        guard letters.count >= minimumLetterCount else {
            return nil
        }
        
        let uppercaseCount = letters.filter { CharacterSet.uppercaseLetters.contains($0) }.count
        let uppercaseRatio = Double(uppercaseCount) / Double(letters.count)
        
        guard uppercaseRatio >= uppercaseRatioThreshold else {
            return nil
        }
        
        return ModerationIssue(
            ruleID: id,
            message: "Text contains an excessive amount of uppercase letters.",
            severity: severity,
            suggestedDecision: decision
        )
    }
}
