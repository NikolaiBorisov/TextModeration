import Foundation

/// A rule that reports text containing more user mentions than allowed.
public struct MentionRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "mention"
    
    private let maximumAllowedMentions: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    private let expression: NSRegularExpression
    
    /// Creates a mention rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedMentions: The maximum number of mentions allowed before the rule matches.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedMentions: Int = 5,
        severity: ModerationSeverity = .medium,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedMentions = maximumAllowedMentions
        self.severity = severity
        self.decision = decision
        self.expression = try! NSRegularExpression(
            pattern: #"(?<!\w)@[A-Za-z0-9_]{1,30}\b"#,
            options: []
        )
    }
    
    /// Evaluates whether the text contains more mentions than allowed.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let mentionCount = expression.matches(in: text, options: [], range: range).count
        
        guard mentionCount > maximumAllowedMentions else {
            return nil
        }
        
        return ModerationIssue(
            ruleID: id,
            message: "Text contains more mentions than allowed.",
            severity: severity,
            suggestedDecision: decision
        )
    }
}
