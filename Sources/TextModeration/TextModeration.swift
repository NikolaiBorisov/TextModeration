import Foundation

/// The final moderation decision for a piece of text.
public enum ModerationDecision: Equatable, Sendable {
    /// The text passed all configured moderation rules.
    case allowed
    
    /// The text matched one or more rules and should be reviewed or handled carefully.
    case flagged
    
    /// The text matched one or more rules that recommend preventing publication.
    case blocked
}

/// The severity of a moderation issue reported by a rule.
public enum ModerationSeverity: Int, Comparable, Sendable {
    /// A minor issue that may not require user-facing action.
    case low = 1
    
    /// A notable issue that may require review or warning.
    case medium = 2
    
    /// A serious issue that may require blocking the text.
    case high = 3
    
    public static func < (lhs: ModerationSeverity, rhs: ModerationSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A single issue found by a moderation rule.
public struct ModerationIssue: Equatable, Sendable {
    /// The stable identifier of the rule that produced this issue.
    public let ruleID: String
    
    /// A human-readable explanation of the issue.
    public let message: String
    
    /// The severity assigned by the rule.
    public let severity: ModerationSeverity
    
    /// The decision this issue recommends for the full moderation result.
    public let suggestedDecision: ModerationDecision
    
    /// Creates a moderation issue.
    public init(
        ruleID: String,
        message: String,
        severity: ModerationSeverity,
        suggestedDecision: ModerationDecision
    ) {
        self.ruleID = ruleID
        self.message = message
        self.severity = severity
        self.suggestedDecision = suggestedDecision
    }
}

/// The result of evaluating text against a set of moderation rules.
public struct ModerationResult: Equatable, Sendable {
    /// The final decision produced from all matching issues.
    public let decision: ModerationDecision
    
    /// The issues reported by the configured rules.
    public let issues: [ModerationIssue]
    
    /// A Boolean value indicating whether the text is allowed.
    public var isAllowed: Bool {
        decision == .allowed
    }
    
    /// Creates a moderation result.
    public init(decision: ModerationDecision, issues: [ModerationIssue]) {
        self.decision = decision
        self.issues = issues
    }
}

/// A rule that evaluates text and optionally reports a moderation issue.
public protocol ModerationRule: Sendable {
    /// A stable identifier for the rule.
    var id: String { get }
    
    /// Evaluates text and returns an issue when the rule matches.
    func evaluate(_ text: String) -> ModerationIssue?
}

/// Evaluates text against a configurable collection of moderation rules.
public struct TextModerator: Sendable {
    private let rules: [any ModerationRule]
    
    /// Creates a text moderator with the provided rules.
    public init(rules: [any ModerationRule]) {
        self.rules = rules
    }
    
    /// Evaluates text and returns a moderation result.
    public func moderate(_ text: String) -> ModerationResult {
        let issues = rules.compactMap { rule in
            rule.evaluate(text)
        }
        
        let decision = Self.decision(for: issues)
        
        return ModerationResult(
            decision: decision,
            issues: issues
        )
    }
    
    private static func decision(for issues: [ModerationIssue]) -> ModerationDecision {
        if issues.contains(where: { $0.suggestedDecision == .blocked }) {
            return .blocked
        }
        
        if issues.contains(where: { $0.suggestedDecision == .flagged }) {
            return .flagged
        }
        
        return .allowed
    }
}
