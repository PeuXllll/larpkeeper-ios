import SwiftUI

/// Settings: wallet name/address editing, demo data controls and honest info.
struct SettingsView: View {
    @EnvironmentObject private var store: DemoStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Wallet (cosmetic)") {
                    TextField("Wallet name", text: $store.walletName)
                    TextField("Fake address", text: $store.walletAddress)
                        .font(.system(.footnote, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Button(role: .destructive) {
                        store.assets = DemoStore.defaultAssets
                        store.transactions = []
                    } label: {
                        Label("Reset demo data", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("Restores the starter fake portfolio and clears fake history.")
                }

                Section("Reality check") {
                    Label("No real funds anywhere", systemImage: "banknote")
                    Label("No blockchain connection at all", systemImage: "link.badge.plus")
                    Label("Data never leaves this device", systemImage: "iphone")
                    Label("Meant for jokes, skits and screen recordings", systemImage: "camera.viewfinder")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Section {
                    Button {
                        store.hasCompletedIntro = false
                        dismiss()
                    } label: {
                        Label("Show disclaimer again on next launch", systemImage: "exclamationmark.triangle")
                    }
                } footer: {
                    Text("The disclaimer always shows on every cold launch; this replays it immediately.")
                }

                Section("About") {
                    LabeledContent("App", value: "LarpKeeper iOS")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Mode", value: "100% fake")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
