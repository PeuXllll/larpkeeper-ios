import SwiftUI

/// Fake transaction history.
struct HistoryView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            Group {
                if store.transactions.isEmpty {
                    empty
                } else {
                    list
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var list: some View {
        List {
            Section {
                ForEach(store.transactions) { tx in
                    row(tx)
                }
            } footer: {
                Label("All of these events are fictional.", systemImage: "theatermasks")
                    .font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func row(_ tx: FakeTransaction) -> some View {
        HStack(spacing: 12) {
            Text(tx.assetIcon)
                .font(.system(size: 24))
                .frame(width: 42, height: 42)
                .background(Color(uiColor: .tertiarySystemFill), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.isIncoming ? "Received \(tx.assetSymbol)" : "Sent \(tx.assetSymbol)")
                    .font(.body.weight(.semibold))
                if !tx.note.isEmpty {
                    Text(tx.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(tx.counterparty)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(tx.signedAmountText + " " + tx.assetSymbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tx.isIncoming ? Color.green : Color.primary)
                Text(tx.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var empty: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No fake activity yet")
                .font(.headline)
            Text("Send some imaginary coins and the fake history shows up here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
