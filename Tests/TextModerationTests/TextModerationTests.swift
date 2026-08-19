import Testing
@testable import TextModeration

/// Verifies that text within the configured length range does not produce an issue.
@Test func textLengthRuleAllowsTextWithinLimits() {
    let rule = TextLengthRule(minimumLength: 3, maximumLength: 10)
    
    let issue = rule.evaluate("Hello")
    
    #expect(issue == nil)
}

/// Verifies that text shorter than the minimum length produces a moderation issue.
@Test func textLengthRuleFlagsTextShorterThanMinimum() throws {
    let rule = TextLengthRule(minimumLength: 3, maximumLength: 10)
    
    let issue = try #require(rule.evaluate("Hi"))
    
    #expect(issue.ruleID == "text_length")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that text longer than the maximum length produces a moderation issue.
@Test func textLengthRuleFlagsTextLongerThanMaximum() throws {
    let rule = TextLengthRule(minimumLength: 3, maximumLength: 10)
    
    let issue = try #require(rule.evaluate("This is too long"))
    
    #expect(issue.ruleID == "text_length")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that the moderator returns `.blocked` when any matching rule recommends blocking.
@Test func textModeratorReturnsBlockedWhenAnyRuleBlocks() {
    let moderator = TextModerator(rules: [
        TextLengthRule(
            maximumLength: 5,
            severity: .high,
            decision: .blocked
        )
    ])
    
    let result = moderator.moderate("Too long")
    
    #expect(result.decision == .blocked)
    #expect(result.isAllowed == false)
    #expect(result.issues.count == 1)
}

/// Verifies that normal mixed-case text does not produce an excessive caps issue.
@Test func excessiveCapsRuleAllowsMixedCaseText() {
    let rule = ExcessiveCapsRule()
    
    let issue = rule.evaluate("This is a normal message.")
    
    #expect(issue == nil)
}

/// Verifies that short uppercase text does not produce an excessive caps issue.
@Test func excessiveCapsRuleAllowsShortUppercaseText() {
    let rule = ExcessiveCapsRule()
    
    let issue = rule.evaluate("NASA")
    
    #expect(issue == nil)
}

/// Verifies that text with too many uppercase letters produces a moderation issue.
@Test func excessiveCapsRuleFlagsMostlyUppercaseText() throws {
    let rule = ExcessiveCapsRule()
    
    let issue = try #require(rule.evaluate("THIS IS WAY TOO MUCH"))
    
    #expect(issue.ruleID == "excessive_caps")
    #expect(issue.severity == .low)
    #expect(issue.suggestedDecision == .flagged)
}
