import Foundation

/// A fake transaction rendered in the history screen.
struct FakeTransaction: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var kind: Kind
    var assetSymbol: String
    var assetIcon: String
    /// Unsigned amount string, e.g. "12.5".
    var amount: String
    var counterparty: String
    var date: Date
    var note: String

    enum Kind: String, Codable, Equatable, Hashable {
        case sent
        case received
    }

    var isIncoming: Bool { kind == .received }

    var signedAmountText: String {
        (isIncoming ? "+" : "-") + amount
    }
}
