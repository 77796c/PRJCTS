#if canImport(SwiftUI) && canImport(StoreKit)
import SwiftUI
#if canImport(SubuddyCore)
import SubuddyCore
#endif

struct ContentView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                BannerAdView()
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 64))
                        .foregroundStyle(.accent)
                    Text("Welcome to Subuddy")
                        .font(.largeTitle)
                        .bold()
                    Text("Track your habits while we keep the experience clean and delightful.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .toolbar {
                Button(action: { isShowingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                NavigationStack {
                    SettingsView()
                        .environmentObject(storeKitManager)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreKitManager())
}
#endif
