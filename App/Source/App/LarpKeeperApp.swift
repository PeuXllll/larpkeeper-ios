import SwiftUI

@main
struct LarpKeeperApp: App {
    @StateObject private var store = DemoStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(Self.accent)
        }
    }

    static let accent = Color(red: 0.20, green: 0.56, blue: 0.98)
}
