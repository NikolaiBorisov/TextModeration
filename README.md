# TextModeration

TextModeration is a native Swift Package for rule-based, on-device moderation of user-generated text.

It helps Swift apps prevent or flag text that matches configurable unsafe, spammy, privacy-sensitive, or undesirable content rules without sending text to a server.

## Features

- Native Swift Package
- Runs entirely on-device
- No external APIs
- No server-side moderation
- No third-party dependencies
- Configurable moderation rules
- Clear moderation decisions: `.allowed`, `.flagged`, or `.blocked`
- Unit-tested rule behavior

## Installation

Add this package in Xcode:

```text
    File > Add Package Dependencies...
```

Use the repository URL:

```text
    https://github.com/NikolaiBorisov/TextModeration
```

Then import the package:

```swift
    import TextModeration
```

## Basic Usage

```swift
    import TextModeration
    
    let result = TextModerator.default.moderate("HELLOOOOOOOO!!!")
    
    switch result.decision {
        case .allowed:
        print("Text can be published.")
        case .flagged:
        print("Text should be reviewed or handled carefully.")
        case .blocked:
        print("Text should not be published.")
    }
```

## Handling Results In An App

TextModeration does not show alerts, toasts, sheets, or other UI. It returns a structured result so each app can decide how to handle moderation.

```swift
    let result = TextModerator.default.moderate(comment)
    
    guard result.decision != .blocked else {
        errorMessage = result.issues.first?.message ?? "Please edit your text before posting."
        return
    }
    
    publish(comment)
```

Apps can also inspect individual issues:

```swift
    for issue in result.issues {
        print(issue.ruleID)
        print(issue.message)
        print(issue.severity)
    }
```

## Custom Rules

You can configure a moderator with only the rules your app needs:

```swift
    let moderator = TextModerator(rules: [
                                          TextLengthRule(maximumLength: 500),
                                          LinkRule(),
                                          MentionRule(),
                                          SpamRule(),
                                          PersonalDataRule()
                                          ])
                                          
                                          let result = moderator.moderate("Visit https://example.com")
```

## Available Rules

### TextLengthRule

Reports text that is shorter or longer than configured character limits.

```swift
    TextLengthRule(
                   minimumLength: 3,
                   maximumLength: 500
                   )
```

### ExcessiveCapsRule

Reports text with an excessive ratio of uppercase letters.

```swift
    ExcessiveCapsRule(
                      minimumLetterCount: 8,
                      uppercaseRatioThreshold: 0.7
                      )
```

### RepeatedCharactersRule

Reports text containing the same character repeated too many times in a row.

```swift
    RepeatedCharactersRule(
                           maximumAllowedRepeats: 4
                           )
```

### SpecialCharactersRule

Reports excessive use of special characters or symbol-only text.

```swift
SpecialCharactersRule(
    maximumAllowedSpecialCharacterCount: 12,
    maximumSpecialCharacterRatio: 0.4,
    allowsSymbolOnlyText: false
)

### LinkRule

Reports text containing more URLs than allowed.

```swift
    LinkRule(
             maximumAllowedLinks: 0
             )
```

### MentionRule

Reports text containing more `@username` mentions than allowed.

```swift
    MentionRule(
                maximumAllowedMentions: 5
                )
```

### SpamRule

Reports common spam-like patterns such as configured spam keywords, repeated neighboring words, or excessive exclamation marks.

```swift
    SpamRule(
             spamKeywords: ["buy now", "free money", "limited offer"],
             maximumAllowedExclamationMarks: 5,
             maximumAllowedRepeatedPhraseCount: 2
             )
```

### PersonalDataRule

Reports possible personal data such as email addresses and phone numbers.

```swift
    PersonalDataRule(
                     detectsEmailAddresses: true,
                     detectsPhoneNumbers: true,
                     detectsPostalAddresses: false
                     )
```

### RepetitionRule

Reports repeated neighboring words or repeated neighboring phrases.

```swift
    RepetitionRule(
                   maximumAllowedRepeatedWordCount: 2,
                   maximumAllowedRepeatedPhraseCount: 2,
                   phraseLength: 2
                   )
```

### ProfanityRule

Reports text matching developer-provided prohibited words or phrases.

TextModeration does not include a built-in profanity dataset. Apps provide their own terms according to their language, audience, and community standards.

```swift
    ProfanityRule(
                  prohibitedTerms: [
                                    "blockedword",
                                    "blocked phrase"
                                    ],
                  decision: .blocked
                  )
```

The rule normalizes common obfuscation patterns before matching, including case, diacritics, punctuation separators, repeated characters, and simple number or symbol substitutions.

### EmojiRule

Reports excessive or repeated emoji usage.

```swift
    EmojiRule(
              maximumAllowedEmojiCount: 8,
              maximumEmojiRatio: 0.5,
              maximumAllowedRepeatedEmojiCount: 3,
              allowsEmojiOnlyText: true
              )
```

## Creating A Custom Rule

Rules conform to `ModerationRule`:

```swift
    struct MyRule: ModerationRule {
        let id = "my_rule"
        
        func evaluate(_ text: String) -> ModerationIssue? {
            guard text.contains("example") else {
                return nil
            }
            
            return ModerationIssue(
                                   ruleID: id,
                                   message: "Text contains a disallowed example term.",
                                   severity: .medium,
                                   suggestedDecision: .flagged
                                   )
        }
    }
```

## Privacy

TextModeration runs entirely on-device. It does not make network requests, call external APIs, or send text to any server.

## Limitations

TextModeration is rule-based. It can detect text that matches configured patterns, but it cannot reliably understand every form of harmful meaning, sarcasm, contextual abuse, threats, harassment, or intentionally disguised content.

For high-risk communities or legally sensitive use cases, use TextModeration as one layer in a broader moderation strategy.

## Requirements

- Swift 6.0 or later
- Apple platforms supported by Swift Package Manager

## License

TextModeration is available under the MIT license.
