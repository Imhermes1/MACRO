import SwiftUI

struct SmartGroceryView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var aiService: AIService
    @State private var textInput = ""
    @State private var groceryList: [String] = []
    @State private var selectedTabString: String = "Shop"
    
    // Map ContentViewTab to String for LiquidGlassNavbarIcon
    private func tabToString(_ tab: ContentViewTab) -> String {
        return tab.title
    }
    
    private func stringToTab(_ string: String) -> ContentViewTab {
        switch string {
        case "Home": return .home
        case "Coach": return .coach
        case "Voice": return .voice
        case "Shop": return .shop
        case "Analytics": return .analytics
        case "More": return .more
        default: return .shop
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation
            LiquidGlassNavbarIcon(
                selectedTab: $selectedTabString,
                tabs: ["Home", "Coach", "Voice", "Shop", "Analytics", "More"],
                onTabSelected: { tabString in
                    selectedTabString = tabString
                    selectedTab = stringToTab(tabString)
                }
            )
            .zIndex(1000)
            
            // Header
            VStack(spacing: 8) {
                Text("Smart Grocery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AI-powered shopping lists")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Feature Icon
                    ZStack {
                        Circle()
                            .fill(Material.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                    
                    // Coming Soon Badge
                    Text("Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Feature Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming Features:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            featureRow(icon: "brain", text: "AI-powered grocery suggestions")
                            featureRow(icon: "cart.fill", text: "Smart shopping lists")
                            featureRow(icon: "barcode", text: "Barcode scanning")
                            featureRow(icon: "location.fill", text: "Store integration")
                            featureRow(icon: "dollarsign.circle", text: "Price comparison")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Input Bar for grocery shopping
            LiquidGlassInputBar(
                text: $textInput,
                placeholder: "Add items to grocery list...",
                quickActions: [
                    QuickAction(title: "Scan", icon: "barcode", color: .blue) {
                        // Handle barcode scan
                    },
                    QuickAction(title: "Recipe", icon: "book.fill", color: .green) {
                        // Handle recipe-based shopping
                    },
                    QuickAction(title: "Store", icon: "storefront", color: .orange) {
                        // Handle store locator
                    }
                ],
                onSend: { item in
                    addGroceryItem(item)
                },
                onMicTap: {
                    // Handle voice input for grocery items
                },
                onCameraTap: {
                    // Handle camera for product recognition
                }
            )
        }
        .onAppear {
            selectedTabString = tabToString(selectedTab)
        }
        .onChange(of: selectedTab) { _, newTab in
            selectedTabString = tabToString(newTab)
        }
    }
    
    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
    
    private func addGroceryItem(_ item: String) {
        guard !item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        groceryList.append(item)
        textInput = ""
        
        // In a real implementation, this would save to database
        // and potentially use AI to categorize or suggest related items
    }
}

// MARK: - Preview
struct SmartGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGroceryView(selectedTab: .constant(.shop))
            .preferredColorScheme(.dark)
    }
}
