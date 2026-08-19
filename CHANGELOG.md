
# Changelog

All notable changes to TextModeration will be documented in this file.

## [0.1.0] - 2026-08-19

### Added

- Initial Swift Package structure.
- Core moderation API:
- `ModerationDecision`
- `ModerationSeverity`
- `ModerationIssue`
- `ModerationResult`
- `ModerationRule`
- `TextModerator`
- Default moderator configuration.
- Text moderation rules:
- `TextLengthRule`
- `ExcessiveCapsRule`
- `RepeatedCharactersRule`
- `LinkRule`
- `MentionRule`
- `SpamRule`
- `PersonalDataRule`
- `RepetitionRule`
- `ProfanityRule`
- `EmojiRule`
- Unit test coverage for core rules and default behavior.
