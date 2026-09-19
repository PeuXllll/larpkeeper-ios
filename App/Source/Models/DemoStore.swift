import Foundation
import Combine

/// Persisted wallet state. Everything here is fake — stored locally on device,
/// never touching any network, chain, or real wallet infrastructure.
final class DemoStore: ObservableObject {

    // MARK: - Published state

    @Published var assets: [FakeAsset] {
        didSet { persist() }
    }
    @Published var transactions: [FakeTransaction] {
        didSet { persist() }
    }
    @Published var walletName: String {
        didSet { persist() }
    }
    @Published var walletAddress: String {
        didSet { persist() }
    }
    @Published var hasCompletedIntro: Bool {
        didSet { persist() }
    }

    // MARK: - Init

    init() {
        let data = Self.loadJSON()
        let stored = data.flatMap { try? JSONDecoder().decode(StoredState.self, from: $0) }
        assets = stored?.assets ?? Self.defaultAssets
        transactions = stored?.transactions ?? []
        walletName = stored?.walletName ?? "Main Wallet"
        walletAddress = stored?.walletAddress ?? Self.defaultAddress
        hasCompletedIntro = stored?.hasCompletedIntro ?? false
    }

    // MARK: - Persistence

    private struct StoredState: Codable {
        var assets: [FakeAsset]
        var transactions: [FakeTransaction]
        var walletName: String
        var walletAddress: String
        var hasCompletedIntro: Bool
    }

    private static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("larpkeeper-state.json")
    }

    private static func loadJSON() -> Data? {
        try? Data(contentsOf: fileURL)
    }

    private func persist() {
        let state = StoredState(
            assets: assets,
            transactions: transactions,
            walletName: walletName,
            walletAddress: walletAddress,
            hasCompletedIntro: hasCompletedIntro
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: Self.fileURL, options: .atomic)
        }
    }

    // MARK: - Derived

    var totalBalance: Decimal {
        assets.reduce(0) { $0 + $1.valueDecimal }
    }

    // MARK: - Mutations used by the UI

    func upsert(_ asset: FakeAsset) {
        if let idx = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[idx] = asset
        } else {
            assets.append(asset)
        }
    }

    func deleteAsset(_ asset: FakeAsset) {
        assets.removeAll { $0.id == asset.id }
    }

    func addTransaction(_ tx: FakeTransaction) {
        transactions.insert(tx, at: 0)
    }

    // MARK: - Defaults

    /// Short fake address used for the receive QR screen.
    static let defaultAddress = "UQDemo4LarpKeeper9xNotARealWallet8kQmPzT"

    /// Starter portfolio so the wallet doesn't look empty on first launch.
    static let defaultAssets: [FakeAsset] = [
        FakeAsset(
            name: "Toncoin", symbol: "TON", icon: "💎", chain: "The Open Network",
            amount: "312.84", priceUSD: "5.21", trendUp: true
        ),
        FakeAsset(
            name: "Tether USD", symbol: "USDT", icon: "💵", chain: "The Open Network",
            amount: "1,240.00", priceUSD: "1.00", trendUp: false
        ),
        FakeAsset(
            name: "Notcoin", symbol: "NOT", icon: "🪙", chain: "The Open Network",
            amount: "58400", priceUSD: "0.0084", trendUp: true
        ),
    ]
}
