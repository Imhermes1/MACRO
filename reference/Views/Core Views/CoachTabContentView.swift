import SwiftUI

struct CoachTabContentView: View {
    @EnvironmentObject var userManager: UserManager
    let onTabChange: (ContentViewTab) -> Void
    
    @State private var selectedTab: ContentViewTab = .coach
    @State private var buttonScale: CGFloat = 1.0
    @State private var showDropdown = false
    
    private let tabs = ["Home", "Coach", "Analytics", "More"]
    private let stringToTab: [String: ContentViewTab] = [
        "Home": .home,
        "Coach": .coach,
        "Analytics": .analytics,
        "More": .more
    ]
    private var selectedTabString: String {
        tabs.first(where: { stringToTab[$0] == selectedTab }) ?? "Coach"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header using shared component
            HStack {
                LiquidGlassNavbarIcon(
                    selectedTab: Binding(
                        get: { selectedTabString },
                        set: { newValue in
                            if let mappedTab = stringToTab[newValue] {
                                selectedTab = mappedTab
                                onTabChange(mappedTab)
                            }
                        }
                    ),
                    tabs: tabs,
                    onTabSelected: { tab in
                        if let mappedTab = stringToTab[tab] {
                            selectedTab = mappedTab
                            onTabChange(mappedTab)
                        }
                    }
                )
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Main Content
            if userManager.userTier != .free {
                AICoachView(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            PaywallView()
                                .environmentObject(userManager)
                        }
                        Spacer(minLength: 100)
                    }
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                }
            }
            
            Spacer()
        }
    }
}
