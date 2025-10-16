import SwiftUI
import SwiftData

struct SubscriptionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKey.globalRemindersEnabled) private var globalRemindersEnabled = true

    private let subscription: Subscription?

    @State private var name: String
    @State private var priceString: String
    @State private var currency: String
    @State private var billingPeriod: BillingPeriod
    @State private var customBillingDaysString: String
    @State private var nextChargeDate: Date
    @State private var category: String
    @State private var notes: String
    @State private var providerURL: String
    @State private var reminderLeadTime: Int
    @State private var remindersEnabled: Bool
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?

    init(subscription: Subscription? = nil) {
        self.subscription = subscription

        _name = State(initialValue: subscription?.name ?? "")
        _priceString = State(initialValue: subscription.map { Self.decimalFormatter.string(from: NSDecimalNumber(decimal: $0.price)) ?? "" } ?? "")
        _currency = State(initialValue: subscription?.currency ?? Self.supportedCurrencies.first ?? "USD")
        _billingPeriod = State(initialValue: subscription?.billingPeriod ?? .monthly)
        _customBillingDaysString = State(initialValue: subscription?.customBillingDays.map { String($0) } ?? "")
        _nextChargeDate = State(initialValue: subscription?.nextChargeDate ?? Date())
        _category = State(initialValue: subscription?.category ?? "Other")
        _notes = State(initialValue: subscription?.notes ?? "")
        _providerURL = State(initialValue: subscription?.providerURL ?? "")
        _reminderLeadTime = State(initialValue: subscription?.reminderLeadTime ?? 3)
        _remindersEnabled = State(initialValue: subscription?.remindersEnabled ?? true)
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .name)
                TextField("Category", text: $category)
                    .focused($focusedField, equals: .category)
            }

            Section("Billing") {
                TextField("Price", text: $priceString)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                Picker("Currency", selection: $currency) {
                    ForEach(Self.supportedCurrencies, id: \.self) { code in
                        Text(code)
                    }
                }
                Picker("Billing Period", selection: $billingPeriod) {
                    ForEach(BillingPeriod.allCases, id: \.self) { period in
                        Text(period.displayName)
                    }
                }
                if billingPeriod == .custom {
                    TextField("Custom days", text: $customBillingDaysString)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .customDays)
                }
                DatePicker("Next charge", selection: $nextChargeDate, displayedComponents: .date)
                    .environment(\.locale, Locale.current)
            }

            Section("Reminders") {
                Toggle("Enable reminders", isOn: $remindersEnabled)
                Stepper(value: $reminderLeadTime, in: 0...30) {
                    Text("Notify \(reminderLeadTime) day\(reminderLeadTime == 1 ? "" : "s") before")
                }
                .disabled(!remindersEnabled)
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .focused($focusedField, equals: .notes)
            }

            Section("Provider") {
                TextField("Website", text: $providerURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .providerURL)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(Color.red)
                }
            }
        }
        .navigationTitle(subscription == nil ? "New Subscription" : "Edit Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(!isValid)
            }
        }
        .onAppear {
            if subscription == nil {
                remindersEnabled = globalRemindersEnabled
            }
        }
        .onChange(of: billingPeriod) { newValue in
            if newValue != .custom {
                customBillingDaysString = ""
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        decimalValue != nil &&
        decimalValue ?? 0 > 0 &&
        (!requiresCustomDays || (Int(customBillingDaysString) ?? 0) > 0)
    }

    private var requiresCustomDays: Bool {
        billingPeriod == .custom
    }

    private var decimalValue: Decimal? {
        if let number = Self.decimalFormatter.number(from: priceString) {
            return number.decimalValue
        }
        return Decimal(string: priceString.replacingOccurrences(of: ",", with: "."))
    }

    private func save() {
        guard let price = decimalValue, price > 0 else {
            errorMessage = "Enter a valid price"
            return
        }

        var customDays: Int?
        if requiresCustomDays {
            guard let days = Int(customBillingDaysString), days > 0 else {
                errorMessage = "Enter days greater than zero"
                return
            }
            customDays = days
        }

        let trimmedURL = providerURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedURL.isEmpty, URL(string: trimmedURL) == nil {
            errorMessage = "Enter a valid URL"
            return
        }

        errorMessage = nil

        if let subscription {
            subscription.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.price = price
            subscription.currency = currency
            subscription.billingPeriod = billingPeriod
            subscription.customBillingDays = customDays
            subscription.nextChargeDate = nextChargeDate
            subscription.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.notes = notes
            subscription.providerURL = trimmedURL.isEmpty ? nil : trimmedURL
            subscription.reminderLeadTime = reminderLeadTime
            subscription.remindersEnabled = remindersEnabled
            subscription.updatedAt = Date()
        } else {
            let newSubscription = Subscription(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                price: price,
                currency: currency,
                billingPeriod: billingPeriod,
                customBillingDays: customDays,
                nextChargeDate: nextChargeDate,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes,
                providerURL: trimmedURL.isEmpty ? nil : trimmedURL,
                reminderLeadTime: reminderLeadTime,
                remindersEnabled: remindersEnabled
            )
            modelContext.insert(newSubscription)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension SubscriptionFormView {
    enum Field: Hashable {
        case name
        case price
        case customDays
        case category
        case notes
        case providerURL
    }

    static let supportedCurrencies: [String] = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY"]

    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

#Preview {
    NavigationStack {
        SubscriptionFormView()
    }
    .modelContainer(PreviewData.container)
}
