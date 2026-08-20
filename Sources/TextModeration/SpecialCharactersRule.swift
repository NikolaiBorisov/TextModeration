import Foundation

/// A rule that reports excessive use of special characters or symbol-only text.
public struct SpecialCharactersRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "special_characters"
    
    private let maximumAllowedSpecialCharacterCount: Int
    private let maximumSpecialCharacterRatio: Double
    private let allowsSymbolOnlyText: Bool
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a special characters rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedSpecialCharacterCount: The maximum number of special characters allowed.
    ///   - maximumSpecialCharacterRatio: The maximum ratio of special characters to non-whitespace characters.
    ///   - allowsSymbolOnlyText: A Boolean value indicating whether text made only of symbols is allowed.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedSpecialCharacterCount: Int = 12,
        maximumSpecialCharacterRatio: Double = 0.4,
        allowsSymbolOnlyText: Bool = false,
        severity: ModerationSeverity = .low,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedSpecialCharacterCount = maximumAllowedSpecialCharacterCount
        self.maximumSpecialCharacterRatio = maximumSpecialCharacterRatio
        self.allowsSymbolOnlyText = allowsSymbolOnlyText
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains excessive special character usage.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let nonWhitespaceScalars = text.unicodeScalars.filter { !$0.properties.isWhitespace }
        
        guard !nonWhitespaceScalars.isEmpty else {
            return nil
        }
        
        let specialCharacterCount = nonWhitespaceScalars.filter(Self.isSpecialCharacter).count
        
        guard specialCharacterCount > 0 else {
            return nil
        }
        
        if specialCharacterCount > maximumAllowedSpecialCharacterCount {
            return issue(message: "Text contains more special characters than allowed.")
        }
        
        let specialCharacterRatio = Double(specialCharacterCount) / Double(nonWhitespaceScalars.count)
        
        if specialCharacterRatio > maximumSpecialCharacterRatio {
            return issue(message: "Text contains a high ratio of special characters.")
        }
        
        if !allowsSymbolOnlyText && specialCharacterCount == nonWhitespaceScalars.count {
            return issue(message: "Text contains only special characters.")
        }
        
        return nil
    }
    
    private static func isSpecialCharacter(_ scalar: UnicodeScalar) -> Bool {
        if CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar) {
            return false
        }
        
        if scalar.properties.isWhitespace {
            return false
        }
        
        return true
    }
    
    private func issue(message: String) -> ModerationIssue {
        ModerationIssue(
            ruleID: id,
            message: message,
            severity: severity,
            suggestedDecision: decision
        )
    }
}
