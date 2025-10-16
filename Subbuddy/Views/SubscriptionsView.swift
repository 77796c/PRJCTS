import SwiftUI

struct SubscriptionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(Color.appAccent)

            Text("Track Subscriptions")
                .font(.title2.bold())

            Text("Manage your recurring expenses, set reminders, and keep your finances on track.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SubscriptionsView()
    }
}
