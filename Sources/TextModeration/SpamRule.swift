import Foundation

/// A rule that reports common spam-like text patterns.
public struct SpamRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "spam"
    
    private let spamKeywords: [String]
    private let maximumAllowedExclamationMarks: Int
    private let maximumAllowedRepeatedPhraseCount: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a spam rule.
    ///
    /// - Parameters:
    ///   - spamKeywords: Case-insensitive keywords or phrases that should be treated as spam indicators.
    ///   - maximumAllowedExclamationMarks: The maximum number of exclamation marks allowed before the rule matches.
    ///   - maximumAllowedRepeatedPhraseCount: The maximum number of repeated neighboring words allowed before the rule matches.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        spamKeywords: [String] = ["buy now", "free money", "limited offer"],
        maximumAllowedExclamationMarks: Int = 5,
        maximumAllowedRepeatedPhraseCount: Int = 2,
        severity: ModerationSeverity = .medium,
        decision: ModerationDecision = .flagged
    ) {
        self.spamKeywords = spamKeywords.map { $0.lowercased() }
        self.maximumAllowedExclamationMarks = maximumAllowedExclamationMarks
        self.maximumAllowedRepeatedPhraseCount = maximumAllowedRepeatedPhraseCount
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains spam-like patterns.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let normalizedText = text.lowercased()
        
        if containsSpamKeyword(in: normalizedText) {
            return issue(message: "Text contains a spam-like keyword or phrase.")
        }
        
        if containsTooManyExclamationMarks(in: text) {
            return issue(message: "Text contains too many exclamation marks.")
        }
        
        if containsRepeatedNeighboringWords(in: normalizedText) {
            return issue(message: "Text contains repeated spam-like wording.")
        }
        
        return nil
    }
    
    private func containsSpamKeyword(in text: String) -> Bool {
        spamKeywords.contains { keyword in
            !keyword.isEmpty && text.contains(keyword)
        }
    }
    
    private func containsTooManyExclamationMarks(in text: String) -> Bool {
        text.filter { $0 == "!" }.count > maximumAllowedExclamationMarks
    }
    
    private func containsRepeatedNeighboringWords(in text: String) -> Bool {
        let words = text
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
        
        guard !words.isEmpty else {
            return false
        }
        
        var previousWord: String?
        var repeatCount = 0
        
        for word in words {
            if word == previousWord {
                repeatCount += 1
            } else {
                previousWord = word
                repeatCount = 1
            }
            
            if repeatCount > maximumAllowedRepeatedPhraseCount {
                return true
            }
        }
        
        return false
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
