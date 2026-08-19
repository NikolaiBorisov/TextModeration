import Foundation

/// A rule that reports text containing one or more URLs.
public struct LinkRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "link"
    
    private let maximumAllowedLinks: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a link rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedLinks: The maximum number of URLs allowed before the rule matches.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedLinks: Int = 0,
        severity: ModerationSeverity = .medium,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedLinks = maximumAllowedLinks
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains more URLs than allowed.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        let linkCount = detector?.matches(in: text, options: [], range: range).count ?? 0
        
        guard linkCount > maximumAllowedLinks else {
            return nil
        }
        
        return ModerationIssue(
            ruleID: id,
            message: "Text contains more links than allowed.",
            severity: severity,
            suggestedDecision: decision
        )
    }
}
