import Foundation

/// A rule that reports repeated words or repeated neighboring phrases.
public struct RepetitionRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "repetition"
    
    private let maximumAllowedRepeatedWordCount: Int
    private let maximumAllowedRepeatedPhraseCount: Int
    private let phraseLength: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a repetition rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedRepeatedWordCount: The maximum number of identical neighboring words allowed.
    ///   - maximumAllowedRepeatedPhraseCount: The maximum number of identical neighboring phrases allowed.
    ///   - phraseLength: The number of words that make up a phrase.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedRepeatedWordCount: Int = 2,
        maximumAllowedRepeatedPhraseCount: Int = 2,
        phraseLength: Int = 2,
        severity: ModerationSeverity = .medium,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedRepeatedWordCount = maximumAllowedRepeatedWordCount
        self.maximumAllowedRepeatedPhraseCount = maximumAllowedRepeatedPhraseCount
        self.phraseLength = phraseLength
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains repeated words or repeated neighboring phrases.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let words = normalizedWords(from: text)
        
        if containsRepeatedWords(in: words) {
            return issue(message: "Text contains repeated neighboring words.")
        }
        
        if containsRepeatedPhrases(in: words) {
            return issue(message: "Text contains repeated neighboring phrases.")
        }
        
        return nil
    }
    
    private func normalizedWords(from text: String) -> [String] {
        text
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
    }
    
    private func containsRepeatedWords(in words: [String]) -> Bool {
        var previousWord: String?
        var repeatCount = 0
        
        for word in words {
            if word == previousWord {
                repeatCount += 1
            } else {
                previousWord = word
                repeatCount = 1
            }
            
            if repeatCount > maximumAllowedRepeatedWordCount {
                return true
            }
        }
        
        return false
    }
    
    private func containsRepeatedPhrases(in words: [String]) -> Bool {
        guard phraseLength > 0, words.count >= phraseLength * 2 else {
            return false
        }
        
        var index = 0
        
        while index + phraseLength <= words.count {
            let phrase = Array(words[index..<(index + phraseLength)])
            var repeatCount = 1
            var nextIndex = index + phraseLength
            
            while nextIndex + phraseLength <= words.count {
                let nextPhrase = Array(words[nextIndex..<(nextIndex + phraseLength)])
                
                if nextPhrase == phrase {
                    repeatCount += 1
                    nextIndex += phraseLength
                } else {
                    break
                }
                
                if repeatCount > maximumAllowedRepeatedPhraseCount {
                    return true
                }
            }
            
            index += 1
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
