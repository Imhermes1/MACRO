import SwiftUI
import Charts

struct AnalyticsView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var dataManager: FoodDataManager
    @State private var textInput = ""
    @State private var selectedTabString: String = "Analytics"
    @State private var selectedPeriod: AnalyticsPeriod = .week
    
    enum AnalyticsPeriod: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
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
        default: return .analytics
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
                Text("Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Professional insights & data")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(AnalyticsPeriod.allCases, id: \.rawValue) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    
                    // Feature Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 120, height: 120)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.indigo)
                    }
                    
                    // Coming Soon Badge
                    Text("Professional Analytics Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Feature Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Professional Features:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            featureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced nutrition tracking")
                            featureRow(icon: "brain.head.profile", text: "AI-powered insights")
                            featureRow(icon: "doc.text.magnifyingglass", text: "Detailed reports")
                            featureRow(icon: "square.and.arrow.up", text: "Professional data export")
                            featureRow(icon: "target", text: "Goal progression analysis")
                            featureRow(icon: "calendar.badge.clock", text: "Historical trends")
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
            
            // Input Bar for analytics queries
            LiquidGlassInputBar(
                text: $textInput,
                placeholder: "Ask about your nutrition data...",
                quickActions: [
                    QuickAction(title: "Export", icon: "square.and.arrow.up", color: .blue) {
                        // Handle data export
                    },
                    QuickAction(title: "Report", icon: "doc.text", color: .green) {
                        // Handle report generation
                    },
                    QuickAction(title: "Trends", icon: "chart.line.uptrend.xyaxis", color: .purple) {
                        // Handle trend analysis
                    }
                ],
                onSend: { query in
                    handleAnalyticsQuery(query)
                },
                onMicTap: {
                    // Handle voice query for analytics
                },
                onCameraTap: {
                    // Handle document/chart capture
                }
            )
        }
        .onAppear {
            selectedTabString = tabToString(selectedTab)
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            selectedTabString = tabToString(newTab)
        }
    }
    
    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.indigo)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
    
    private func handleAnalyticsQuery(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        textInput = ""
        
        // In a real implementation, this would process analytics queries
        // and potentially generate reports or insights
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(selectedTab: .constant(.analytics))
            .preferredColorScheme(.dark)
            .environmentObject(FoodDataManager())
    }
}
