import SwiftUI

/// Root of the app. Shows the launch disclaimer first, then the main tab view.
/// The disclaimer cannot be skipped and reappears on every cold launch by design.
struct RootView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        if store.hasCompletedIntro {
            MainTabView()
        } else {
            DisclaimerGateView()
        }
    }
}

/// Full-screen launch disclaimer. The "I understand" button stays disabled for a
/// beat so it cannot be muscle-memory tapped through.
struct DisclaimerGateView: View {
    @EnvironmentObject private var store: DemoStore
    @State private var canContinue = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            ZStack {
                Circle()
                    .fill(Self.accent.opacity(0.14))
                    .frame(width: 108, height: 108)
                Text("⚠️")
                    .font(.system(size: 52))
            }

            Text("This wallet is fake")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 14) {
                bullet("LarpKeeper is a **prank / demo app**. Every balance, asset, price and transaction in it is invented.")
                bullet("It holds **no real funds** and connects to **no blockchain**. Nothing here can be sent, received, sold or withdrawn.")
                bullet("Numbers you enter are pure fiction and stay on this device only.")
                bullet("Never show this app to anyone as proof of funds or use it to deceive people.")
            }
            .padding(.top, 28)

            Spacer(minLength: 24)

            Button {
                store.hasCompletedIntro = true
            } label: {
                Text("I understand — it's all fake")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.5)

            Button {
                exit(0)
            } label: {
                Text("No, take me out of here")
                    .font(.subheadline)
                    .padding(.top, 12)
            }
            .foregroundStyle(.secondary)

            if !canContinue {
                Text("Read the above to continue…")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .background(Self.accent)
        .overlay {
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .foregroundStyle(.white)
        .task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation { canContinue = true }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.headline)
            Text(LocalizedStringKey(text))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private static let accent = Color(red: 0.20, green: 0.56, blue: 0.98)
}
