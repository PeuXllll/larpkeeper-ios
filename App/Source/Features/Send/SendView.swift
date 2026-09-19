import SwiftUI

/// Fake send flow. Simulates sending, then logs a fake transaction.
struct SendView: View {
    @EnvironmentObject private var store: DemoStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAssetID: UUID?
    @State private var amountText = ""
    @State private var recipient = ""
    @State private var note = ""

    // Fake processing state machine
    @State private var phase: Phase = .form
    @State private var progress = 0.0

    enum Phase { case form, sending, done }

    private var selectedAsset: FakeAsset? {
        store.assets.first { $0.id == selectedAssetID }
    }

    private var amountDecimal: Decimal {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var isValid: Bool {
        selectedAsset != nil &&
        amountDecimal > 0 &&
        amountDecimal <= (selectedAsset?.amountDecimal ?? 0) &&
        !recipient.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .form: form
                case .sending: sending
                case .done: done
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Send (fake)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(phase == .sending)
                    // The fake "transaction" is a 2s animation; don't allow bailing mid-fake.
                }
            }
        }
    }

    // MARK: - Form

    private var form: some View {
        Form {
            Section("Fake asset to send") {
                Picker("Asset", selection: $selectedAssetID) {
                    Text("Pick an asset…").tag(UUID?.none)
                    ForEach(store.assets) { asset in
                        HStack {
                            Text(asset.icon)
                            Text(asset.symbol.isEmpty ? asset.name : asset.symbol)
                        }
                        .tag(UUID?.some(asset.id))
                    }
                }
            }

            Section("Recipient (invented address)") {
                TextField("Fake address, e.g. UQ…", text: $recipient)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section("Amount") {
                HStack {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title3.weight(.bold))
                    if let asset = selectedAsset {
                        Text(asset.symbol)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                if let asset = selectedAsset {
                    Text("Available: \(asset.amountDecimal.formatted(maxFractionDigits: 6)) \(asset.symbol) · \(asset.valueDecimal.asCurrency) (fake)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Note (optional)") {
                TextField("What's this fake transfer for?", text: $note)
            }

            Section {
                Label("No real transfer will happen. This only adds an entry to the fake history.", systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Sending (fake progress)

    private var sending: some View {
        VStack(spacing: 18) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal, 40)

            Text(phaseLabel)
                .font(.headline)
            Text("Simulating a blockchain confirmation…")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await runFakeSend() }
    }

    private var phaseLabel: String {
        progress < 0.4 ? "Broadcasting to fake network…"
        : progress < 0.85 ? "Waiting for fake confirmations…"
        : "Done!"
    }

    private func runFakeSend() async {
        // ~2 seconds of fake progress, no real work anywhere.
        for _ in 0..<50 {
            try? await Task.sleep(nanoseconds: 40_000_000)
            progress = min(1, progress + 0.02)
        }
        commitFakeTransaction()
        phase = .done
    }

    // MARK: - Done

    private var done: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.green.opacity(0.15)).frame(width: 96, height: 96)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)
            }
            Text("Fake send complete")
                .font(.title2.bold())

            if let asset = selectedAsset {
                Text("\(amountText) \(asset.symbol) → \(recipient)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Label("Nothing was actually sent anywhere.", systemImage: "theatermasks")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.85, green: 0.15, blue: 0.25).opacity(0.12), in: Capsule())
                .foregroundStyle(Color(red: 0.85, green: 0.15, blue: 0.25))

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func commitFakeTransaction() {
        guard let asset = selectedAsset else { return }
        var asset = asset
        asset.amount = max(0, asset.amountDecimal - amountDecimal).formatted(maxFractionDigits: 6)
        store.upsert(asset)

        store.addTransaction(FakeTransaction(
            kind: .sent,
            assetSymbol: asset.symbol,
            assetIcon: asset.icon,
            amount: amountText.replacingOccurrences(of: ",", with: "."),
            counterparty: recipient,
            date: Date(),
            note: note
        ))
    }
}
