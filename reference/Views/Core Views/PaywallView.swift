import SwiftUI

@MainActor
struct PaywallView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Liquid Glass styling
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Core Track Premium")
                    .font(.headline).fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 20)
                        
                        Text("Unlock Core Track")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Experience the full power of intelligent nutrition tracking and AI-powered coaching")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Tier Cards
                    VStack(spacing: 20) {
                        // Current Free Tier
                        PaywallTierCard(
                            tier: "Free",
                            price: "Always Free",
                            features: [
                                "Essential calorie tracking",
                                "Manual food entry",
                                "Daily nutrition summary",
                                "Basic progress insights"
                            ],
                            isCurrentTier: true,
                            action: nil
                        )
                        
                        // Basic Tier
                        PaywallTierCard(
                            tier: "Basic",
                            price: "$4.99/month",
                            features: [
                                "Voice-powered meal planning",
                                "Smart shopping lists",
                                "AI nutrition coach (text)",
                                "Barcode scanning",
                                "Advanced analytics",
                                "Custom nutrition goals"
                            ],
                            isRecommended: false,
                            action: { userManager.upgrade(to: .basic) }
                        )
                        
                        // Pro Tier
                        PaywallTierCard(
                            tier: "Pro",
                            price: "$9.99/month",
                            features: [
                                "Everything in Basic",
                                "AI voice conversations",
                                "Photo meal recognition",
                                "Professional data export",
                                "Advanced personalisation",
                                "Priority support",
                                "Unlimited AI interactions"
                            ],
                            isRecommended: true,
                            action: { userManager.upgrade(to: .pro) }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Footer
                    VStack(spacing: 12) {
                        Text("All subscriptions include a 7-day free trial")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Cancel anytime from Settings")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 40)
                }
            }
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 40)
        )
    }
}

// MARK: - Paywall Tier Card (renamed to avoid conflicts)
@MainActor
struct PaywallTierCard: View {
    let tier: String
    let price: String
    let features: [String]
    var isCurrentTier: Bool = false
    var isRecommended: Bool = false
    let action: (() -> Void)?
    
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text(tier)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isRecommended {
                        Text("Recommended")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                }
                
                HStack {
                    Text(price)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
            }
            
            // Features
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                            .padding(.top, 2)
                        
                        Text(feature)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
            
            // Action Button with updated iOS 26 Apple-recommended materials/gradients
            if let action = action {
                if #available(iOS 26, *) {
                    Button(action: action) {
                        Text("Choose \(tier)")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .glassEffect()
                    .foregroundStyle(
                        LinearGradient(
                            colors: isRecommended ? [.orange, .red] : [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                } else {
                    Button(action: action) {
                        Text("Choose \(tier)")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .blur(radius: 0.8)
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: isRecommended ? [.orange, .red] : [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ).opacity(0.5)
                                        )
                                }
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            } else if isCurrentTier {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Current Plan")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}
