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

/// Verifies that text with mentions within the configured limit does not produce an issue.
@Test func mentionRuleAllowsMentionsWithinLimit() {
    let rule = MentionRule(maximumAllowedMentions: 2)
    
    let issue = rule.evaluate("Thanks @alice and @bob")
    
    #expect(issue == nil)
}

/// Verifies that text with too many mentions produces a moderation issue.
@Test func mentionRuleFlagsTooManyMentions() throws {
    let rule = MentionRule(maximumAllowedMentions: 2)
    
    let issue = try #require(rule.evaluate("Hi @alice @bob @carol"))
    
    #expect(issue.ruleID == "mention")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that email addresses are not counted as user mentions.
@Test func mentionRuleDoesNotCountEmailAddresses() {
    let rule = MentionRule(maximumAllowedMentions: 0)
    
    let issue = rule.evaluate("Contact person@example.com")
    
    #expect(issue == nil)
}

/// Verifies that ordinary text does not produce a spam issue.
@Test func spamRuleAllowsOrdinaryText() {
    let rule = SpamRule()
    
    let issue = rule.evaluate("This is a normal message about the project.")
    
    #expect(issue == nil)
}

/// Verifies that configured spam keywords produce a moderation issue.
@Test func spamRuleFlagsSpamKeyword() throws {
    let rule = SpamRule()
    
    let issue = try #require(rule.evaluate("This is a limited offer for you."))
    
    #expect(issue.ruleID == "spam")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that excessive exclamation marks produce a moderation issue.
@Test func spamRuleFlagsExcessiveExclamationMarks() throws {
    let rule = SpamRule(maximumAllowedExclamationMarks: 3)
    
    let issue = try #require(rule.evaluate("Win now!!!!"))
    
    #expect(issue.ruleID == "spam")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that repeated neighboring words produce a moderation issue.
@Test func spamRuleFlagsRepeatedNeighboringWords() throws {
    let rule = SpamRule(maximumAllowedRepeatedPhraseCount: 2)
    
    let issue = try #require(rule.evaluate("buy buy buy now"))
    
    #expect(issue.ruleID == "spam")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that ordinary text does not produce a personal data issue.
@Test func personalDataRuleAllowsOrdinaryText() {
    let rule = PersonalDataRule()
    
    let issue = rule.evaluate("This is a normal public comment.")
    
    #expect(issue == nil)
}

/// Verifies that possible email addresses produce a moderation issue.
@Test func personalDataRuleFlagsEmailAddress() throws {
    let rule = PersonalDataRule()
    
    let issue = try #require(rule.evaluate("Contact me at person@example.com"))
    
    #expect(issue.ruleID == "personal_data")
    #expect(issue.severity == .high)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that possible phone numbers produce a moderation issue.
@Test func personalDataRuleFlagsPhoneNumber() throws {
    let rule = PersonalDataRule()
    
    let issue = try #require(rule.evaluate("Call me at 415-555-2671"))
    
    #expect(issue.ruleID == "personal_data")
    #expect(issue.severity == .high)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that email detection can be disabled.
@Test func personalDataRuleCanDisableEmailDetection() {
    let rule = PersonalDataRule(
        detectsEmailAddresses: false,
        detectsPhoneNumbers: false
    )
    
    let issue = rule.evaluate("Contact me at person@example.com")
    
    #expect(issue == nil)
}

/// Verifies that ordinary text does not produce a repetition issue.
@Test func repetitionRuleAllowsOrdinaryText() {
    let rule = RepetitionRule()
    
    let issue = rule.evaluate("This is a normal message with varied words.")
    
    #expect(issue == nil)
}

/// Verifies that repeated neighboring words produce a moderation issue.
@Test func repetitionRuleFlagsRepeatedWords() throws {
    let rule = RepetitionRule(maximumAllowedRepeatedWordCount: 2)
    
    let issue = try #require(rule.evaluate("hello hello hello"))
    
    #expect(issue.ruleID == "repetition")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that repeated neighboring phrases produce a moderation issue.
@Test func repetitionRuleFlagsRepeatedPhrases() throws {
    let rule = RepetitionRule(
        maximumAllowedRepeatedPhraseCount: 2,
        phraseLength: 2
    )
    
    let issue = try #require(rule.evaluate("buy now buy now buy now"))
    
    #expect(issue.ruleID == "repetition")
    #expect(issue.severity == .medium)
    #expect(issue.suggestedDecision == .flagged)
}

/// Verifies that text is allowed when no prohibited terms are configured.
@Test func profanityRuleAllowsTextWithoutConfiguredTerms() {
    let rule = ProfanityRule(prohibitedTerms: [])
    
    let issue = rule.evaluate("This is a normal message.")
    
    #expect(issue == nil)
}

/// Verifies that exact prohibited words produce a moderation issue.
@Test func profanityRuleFlagsConfiguredWord() throws {
    let rule = ProfanityRule(prohibitedTerms: ["blockedword"])
    
    let issue = try #require(rule.evaluate("This contains blockedword."))
    
    #expect(issue.ruleID == "profanity")
    #expect(issue.severity == .high)
    #expect(issue.suggestedDecision == .blocked)
}

/// Verifies that prohibited phrases produce a moderation issue.
@Test func profanityRuleFlagsConfiguredPhrase() throws {
    let rule = ProfanityRule(prohibitedTerms: ["blocked phrase"])
    
    let issue = try #require(rule.evaluate("This contains a blocked phrase."))
    
    #expect(issue.ruleID == "profanity")
    #expect(issue.severity == .high)
    #expect(issue.suggestedDecision == .blocked)
}

/// Verifies that simple number and symbol substitutions are normalized before matching.
@Test func profanityRuleFlagsObfuscatedTerm() throws {
    let rule = ProfanityRule(prohibitedTerms: ["blockedword"])
    
    let issue = try #require(rule.evaluate("bl0cked-w0rd"))
    
    #expect(issue.ruleID == "profanity")
    #expect(issue.suggestedDecision == .blocked)
}

/// Verifies that repeated characters are collapsed before matching.
@Test func profanityRuleFlagsRepeatedCharacterObfuscation() throws {
    let rule = ProfanityRule(prohibitedTerms: ["blockedword"])
    
    let issue = try #require(rule.evaluate("bloooockedword"))
    
    #expect(issue.ruleID == "profanity")
    #expect(issue.suggestedDecision == .blocked)
}

/// Verifies that emoji or punctuation separators are ignored before matching.
@Test func profanityRuleFlagsSeparatedObfuscation() throws {
    let rule = ProfanityRule(prohibitedTerms: ["blockedword"])
    
    let issue = try #require(rule.evaluate("blocked🔥word"))
    
    #expect(issue.ruleID == "profanity")
    #expect(issue.suggestedDecision == .blocked)
}
