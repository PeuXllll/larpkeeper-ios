import SwiftUI

/// Main tab navigation: Wallet, History, Settings.
struct MainTabView: View {
    var body: some View {
        VStack(spacing: 0) {
            DemoBanner()
            TabView {
                WalletView()
                    .tabItem { Label("Wallet", systemImage: "creditcard") }
                HistoryView()
                    .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        }
    }
}

/// A demo-mode ribbon pinned above every screen so the joke never gets lost,
/// even after the launch disclaimer.
struct DemoBanner: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "theatermasks")
            Text("DEMO WALLET — ALL DATA IS FAKE")
                .font(.caption.weight(.bold).monospaced())
                .kerning(0.6)
            Image(systemName: "theatermasks")
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(Color(red: 0.85, green: 0.15, blue: 0.25))
        .overlay(alignment: .bottom) {
            Rectangle().fill(.black.opacity(0.15)).frame(height: 1)
        }
    }
}
