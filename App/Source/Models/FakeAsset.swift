import Foundation

/// A single fake asset shown in the wallet.
struct FakeAsset: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var symbol: String
    /// Emoji used as the token icon (keeps the app fully offline, no image assets needed).
    var icon: String
    var chain: String
    /// Amount owned, stored as a Decimal-safe string.
    var amount: String
    /// Price per unit in USD, as a string for easy editing.
    var priceUSD: String
    /// Up or down 24h tick, purely cosmetic.
    var trendUp: Bool

    var amountDecimal: Decimal {
        Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var priceDecimal: Decimal {
        Decimal(string: priceUSD.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    /// Total value of the holding in USD.
    var valueDecimal: Decimal {
        amountDecimal * priceDecimal
    }

    var displayName: String {
        name.isEmpty ? symbol : name
    }
}

extension Decimal {
    /// Formats using up to `maxFractionDigits` fractional digits, trimming trailing zeros.
    func formatted(maxFractionDigits: Int) -> String {
        let style = FloatingPointFormatStyle<Double>()
            .precision(.fractionLength(0...maxFractionDigits))
        return style.format(doubleValue)
    }

    var asCurrency: String {
        let style = FloatingPointFormatStyle<Double>()
            .precision(.fractionLength(2...2))
        return "$" + style.format(doubleValue)
    }

    private var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
