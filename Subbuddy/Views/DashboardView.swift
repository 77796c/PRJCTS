import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.appAccent)

                Text("Welcome to Subuddy")
                    .font(.title.bold())
                    .foregroundStyle(.primary)

                Text("Your subscription insights will appear here. Stay tuned as we build out the dashboard experience.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
