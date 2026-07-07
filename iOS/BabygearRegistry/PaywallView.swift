import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.accent)
                    Text("BabygearRegistry Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(.white)
                    Text("Size-outgrown alerts and hand-me-down history")
                        .font(Theme.bodyFont)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal)
                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        Text(purchases.product != nil ? "Upgrade for \(purchases.product!.displayPrice)" : "Upgrade to Pro")
                            .font(Theme.bodyFont.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("paywallUpgradeButton")
                    .padding(.horizontal)

                    Button("Not now") { dismiss() }
                        .accessibilityIdentifier("paywallDismissButton")
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
