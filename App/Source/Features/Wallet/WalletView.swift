import SwiftUI

/// The main wallet screen: total balance, action buttons and the fake asset list.
struct WalletView: View {
    @EnvironmentObject private var store: DemoStore

    enum Sheet: Identifiable {
        case addAsset
        case editAsset(FakeAsset)
        case send
        case receive
        var id: String {
            switch self {
            case .addAsset: return "add"
            case .editAsset(let a): return "edit-\(a.id)"
            case .send: return "send"
            case .receive: return "receive"
            }
        }
    }

    @State private var sheet: Sheet?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard
                    actionButtons
                    assetsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            sheet = .addAsset
                        } label: {
                            Label("Add fake asset", systemImage: "plus.circle")
                        }
                        Button {
                            sheet = .receive
                        } label: {
                            Label("Receive (fake QR)", systemImage: "qrcode")
                        }
                        Divider()
                        Button(role: .destructive) {
                            store.assets = DemoStore.defaultAssets
                            store.transactions = []
                        } label: {
                            Label("Reset demo data", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $sheet) { value in
                switch value {
                case .addAsset:
                    AssetEditorView(asset: nil)
                case .editAsset(let asset):
                    AssetEditorView(asset: asset)
                case .send:
                    SendView()
                case .receive:
                    ReceiveView()
                }
            }
        }
    }

    // MARK: - Balance card

    private var balanceCard: some View {
        VStack(spacing: 6) {
            Text("Total balance")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Text(store.totalBalance.asCurrency)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("simulated balance")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.white.opacity(0.16), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.56, blue: 0.98),
                         Color(red: 0.10, green: 0.30, blue: 0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .foregroundStyle(.white)
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 10) {
            actionButton("qrcode", "Receive") { sheet = .receive }
            actionButton("paperplane.fill", "Send") { sheet = .send }
            actionButton("plus", "Add asset") { sheet = .addAsset }
        }
    }

    private func actionButton(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.14), in: Circle())
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Asset list

    private var assetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My assets")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                ForEach(store.assets) { asset in
                    Button {
                        sheet = .editAsset(asset)
                    } label: {
                        AssetRowView(asset: asset)
                    }
                    .buttonStyle(.plain)
                    if asset.id != store.assets.last?.id {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16))

            if store.assets.isEmpty {
                Text("No fake assets yet — tap “Add asset” to invent one.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(uiColor: .secondarySystemGroupedBackground),
                                in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

/// One row in the asset list.
struct AssetRowView: View {
    let asset: FakeAsset

    var body: some View {
        HStack(spacing: 12) {
            Text(asset.icon)
                .font(.system(size: 26))
                .frame(width: 44, height: 44)
                .background(Color(uiColor: .tertiarySystemFill), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(asset.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(asset.chain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(asset.amountDecimal.formatted(maxFractionDigits: 6))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                HStack(spacing: 3) {
                    Image(systemName: asset.trendUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(asset.trendUp ? Color.green : Color.red)
                    Text(asset.valueDecimal.asCurrency)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
