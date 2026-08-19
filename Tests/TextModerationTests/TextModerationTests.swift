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

/// Verifies that normal repeated letters within the allowed limit do not produce an issue.
@Test func repeatedCharactersRuleAllowsNormalText() {
    let rule = RepeatedCharactersRule(maximumAllowedRepeats: 4)
    
    let issue = rule.evaluate("Cool message!")
    
    #expect(issue == nil)
}

/// Verifies that text with too many identical consecutive letters produces a moderation issue.
@Test func repeatedCharactersRuleFlagsRepeatedLetters() throws {
    let rule = RepeatedCharactersRule(maximumAllowedRepeats: 4)
    
    let issue = try #require(rule.evaluate("heyyyyyy"))
    
    #expect(issue.ruleID == "repeated_characters")
    #expect(issue.severity == .low)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that text with too many identical consecutive symbols produces a moderation issue.
@Test func repeatedCharactersRuleFlagsRepeatedSymbols() throws {
    let rule = RepeatedCharactersRule(maximumAllowedRepeats: 4)
    
    let issue = try #require(rule.evaluate("!!!!!!"))
    
    #expect(issue.ruleID == "repeated_characters")
    #expect(issue.severity == .low)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that the default moderator can be used without manual rule configuration.
@Test func defaultModeratorReturnsResult() {
    let result = TextModerator.default.moderate("Hello world")
    
    #expect(result.decision == .allowed)
    #expect(result.issues.isEmpty)
}

/// Verifies that text without URLs does not produce a link issue.
@Test func linkRuleAllowsTextWithoutLinks() {
    let rule = LinkRule()
    
    let issue = rule.evaluate("This is a normal message.")
    
    #expect(issue == nil)
}

/// Verifies that text containing a URL produces a moderation issue by default.
@Test func linkRuleFlagsTextWithURL() throws {
    let rule = LinkRule()
    
    let issue = try #require(rule.evaluate("Visit https://example.com"))
    
    #expect(issue.ruleID == "link")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that the link rule can allow a configured number of URLs.
@Test func linkRuleAllowsConfiguredNumberOfLinks() {
    let rule = LinkRule(maximumAllowedLinks: 1)
    
    let issue = rule.evaluate("Visit https://example.com")
    
    #expect(issue == nil)
}
