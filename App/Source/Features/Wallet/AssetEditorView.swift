import SwiftUI

/// Create or edit a fake asset. Everything is editable: name, symbol, emoji
/// icon, chain label, amount and price. Nothing leaves the device.
struct AssetEditorView: View {
    @EnvironmentObject private var store: DemoStore
    @Environment(\.dismiss) private var dismiss

    let existing: FakeAsset?

    @State private var name: String
    @State private var symbol: String
    @State private var icon: String
    @State private var chain: String
    @State private var amount: String
    @State private var price: String
    @State private var trendUp: Bool

    @State private var showIconPicker = false

    init(asset: FakeAsset?) {
        existing = asset
        _name = State(initialValue: asset?.name ?? "")
        _symbol = State(initialValue: asset?.symbol ?? "")
        _icon = State(initialValue: asset?.icon ?? "🪙")
        _chain = State(initialValue: asset?.chain ?? "The Open Network")
        _amount = State(initialValue: asset?.amount ?? "")
        _price = State(initialValue: asset?.priceUSD ?? "")
        _trendUp = State(initialValue: asset?.trendUp ?? true)
    }

    private let iconChoices = [
        "🪙", "💎", "💵", "💰", "🐕", "🐸", "🚀", "⚡️", "🔥", "🌙",
        "🤖", "👽", "🦄", "🧿", "🎴", "🏆", "🥇", "🌊", "🍕", "🎩",
    ]

    private var isValid: Bool {
        !symbol.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Asset") {
                    HStack {
                        Button {
                            showIconPicker.toggle()
                        } label: {
                            Text(icon)
                                .font(.system(size: 34))
                                .frame(width: 56, height: 56)
                                .background(Color(uiColor: .tertiarySystemFill), in: Circle())
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Name (e.g. Mooncoin)", text: $name)
                                .font(.body.weight(.semibold))
                            TextField("Symbol (e.g. MOON)", text: $symbol)
                                .font(.subheadline)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                        }
                    }

                    HStack {
                        ForEach(iconChoices.prefix(10), id: \.self) { choice in
                            iconDot(choice)
                        }
                    }
                    if showIconPicker {
                        HStack {
                            ForEach(Array(iconChoices.dropFirst(10)), id: \.self) { choice in
                                iconDot(choice)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Section("Blockchain label") {
                    TextField("Chain name", text: $chain)
                }

                Section {
                    HStack {
                        Text("Amount")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body.weight(.semibold))
                    }
                    HStack {
                        Text("Price per coin ($)")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body.weight(.semibold))
                    }
                    Picker("24h trend (cosmetic)", selection: $trendUp) {
                        Text("Up ↑").tag(true)
                        Text("Down ↓").tag(false)
                    }
                } header: {
                    Text("Numbers — entirely made up")
                } footer: {
                    Text("These numbers are stored on this device only and mean nothing. Total shown: \(currentValue.asCurrency).")
                }

                if existing != nil {
                    Section {
                        Button(role: .destructive) {
                            if let existing {
                                store.deleteAsset(existing)
                            }
                            dismiss()
                        } label: {
                            Label("Delete fake asset", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "New fake asset" : "Edit fake asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var asset = existing ?? FakeAsset(
                            name: "", symbol: "", icon: icon, chain: chain,
                            amount: "0", priceUSD: "0", trendUp: true
                        )
                        asset.name = name.trimmingCharacters(in: .whitespaces)
                        asset.symbol = symbol.trimmingCharacters(in: .whitespaces)
                        asset.icon = icon
                        asset.chain = chain.trimmingCharacters(in: .whitespaces)
                        asset.amount = amount.replacingOccurrences(of: ",", with: ".")
                        asset.priceUSD = price.replacingOccurrences(of: ",", with: ".")
                        asset.trendUp = trendUp
                        store.upsert(asset)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func iconDot(_ choice: String) -> some View {
        Button {
            icon = choice
            showIconPicker = false
        } label: {
            Text(choice)
                .font(.system(size: 22))
                .frame(width: 32, height: 32)
                .background(
                    icon == choice ? Color.accentColor.opacity(0.25) : Color.clear,
                    in: Circle()
                )
        }
        .buttonStyle(.plain)
    }

    private var currentValue: Decimal {
        let amt = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        let prc = Decimal(string: price.replacingOccurrences(of: ",", with: ".")) ?? 0
        return amt * prc
    }
}
