import Foundation

/// A rule that reports text containing possible personal data.
public struct PersonalDataRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "personal_data"
    
    private let detectsEmailAddresses: Bool
    private let detectsPhoneNumbers: Bool
    private let detectsPostalAddresses: Bool
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    private let emailExpression: NSRegularExpression
    private let dataDetector: NSDataDetector?
    
    /// Creates a personal data rule.
    ///
    /// - Parameters:
    ///   - detectsEmailAddresses: A Boolean value indicating whether email addresses should be detected.
    ///   - detectsPhoneNumbers: A Boolean value indicating whether phone numbers should be detected.
    ///   - detectsPostalAddresses: A Boolean value indicating whether postal addresses should be detected.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        detectsEmailAddresses: Bool = true,
        detectsPhoneNumbers: Bool = true,
        detectsPostalAddresses: Bool = false,
        severity: ModerationSeverity = .high,
        decision: ModerationDecision = .flagged
    ) {
        self.detectsEmailAddresses = detectsEmailAddresses
        self.detectsPhoneNumbers = detectsPhoneNumbers
        self.detectsPostalAddresses = detectsPostalAddresses
        self.severity = severity
        self.decision = decision
        self.emailExpression = try! NSRegularExpression(
            pattern: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
            options: [.caseInsensitive]
        )
        
        var checkingTypes: NSTextCheckingResult.CheckingType = []
        
        if detectsPhoneNumbers {
            checkingTypes.insert(.phoneNumber)
        }
        
        if detectsPostalAddresses {
            checkingTypes.insert(.address)
        }
        
        self.dataDetector = checkingTypes.isEmpty
        ? nil
        : try? NSDataDetector(types: checkingTypes.rawValue)
    }
    
    /// Evaluates whether the text contains possible personal data.
    public func evaluate(_ text: String) -> ModerationIssue? {
        if detectsEmailAddresses && containsEmailAddress(in: text) {
            return issue(message: "Text contains a possible email address.")
        }
        
        if containsDetectedPersonalData(in: text) {
            return issue(message: "Text contains possible personal data.")
        }
        
        return nil
    }
    
    private func containsEmailAddress(in text: String) -> Bool {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return emailExpression.firstMatch(in: text, options: [], range: range) != nil
    }
    
    private func containsDetectedPersonalData(in text: String) -> Bool {
        guard let dataDetector else {
            return false
        }
        
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return dataDetector.firstMatch(in: text, options: [], range: range) != nil
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
