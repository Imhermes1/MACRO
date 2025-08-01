// New glassy, expandable calorie/macro summary card for chat
import SwiftUI

@MainActor
struct CalorieProgressCardView: View {
    @EnvironmentObject var dataManager: FoodDataManager
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var isExpanded = false
    @State private var selectedSummaryTab: String = "Summary"

    var body: some View {
        let totals = dataManager.getTodaysTotals()
        let calorieGoal = notificationManager.getCalorieGoal()
        let progress = calorieGoal > 0 ? min(totals.calories / calorieGoal, 1.0) : 0.0
        let percentage = Int(progress * 100)
        let displayColor: Color = {
            switch progress {
            case 0..<0.8: return .green
            case 0.8..<1.0: return .yellow
            default: return .red
            }
        }()

        VStack(spacing: 0) {
            // Summary navigation tabs (internal to this card)
            HStack {
                Button(action: { selectedSummaryTab = "Summary" }) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedSummaryTab == "Summary" ? .orange : .white.opacity(0.6))
                        Text("Summary")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedSummaryTab == "Summary" ? .white : .white.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(selectedSummaryTab == "Summary" ? .orange.opacity(0.2) : Color.clear)
                            .overlay(
                                Capsule()
                                    .stroke(selectedSummaryTab == "Summary" ? .orange.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .adaptiveGlassButton()
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Header summary
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Calories today")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(Int(totals.calories)) / \(Int(calorieGoal))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(percentage)%")
                                .font(.subheadline)
                                .foregroundColor(displayColor)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 6)
                }
            }
            .padding(.top, 18)
            .padding(.horizontal, 20)

            // Calorie progress bar
            ProgressView(value: totals.calories, total: calorieGoal)
                .progressViewStyle(LinearProgressViewStyle(tint: displayColor))
                .frame(height: 8)
                .background(
                    Capsule().fill(Color.white.opacity(0.13))
                )
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

            // Expanded macros
            if isExpanded {
                Divider().background(Color.white.opacity(0.10)).padding(.horizontal, 20)
                HStack(spacing: 18) {
                    MacroBadge(label: "Protein", value: totals.protein, color: .red)
                    MacroBadge(label: "Carbs", value: totals.carbs, color: .orange)
                    MacroBadge(label: "Fat", value: totals.fat, color: .yellow)
                }
                .padding(.top, 6)
                .padding(.bottom, 14)
                .padding(.horizontal, 20)
            } else {
                Spacer(minLength: 8)
            }
        }
        .glassEffect(
            isInteractive: true,
            shape: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: Color.black.opacity(0.13), radius: 10, x: 0, y: 6)
        .padding(.horizontal)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isExpanded)
    }
}

@MainActor
private struct MacroBadge: View {
    let label: String
    let value: Double
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Text("\(Int(value))g")
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct CalorieProgressCardView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieProgressCardView()
            .environmentObject(FoodDataManager())
            .environmentObject(NotificationManager.shared)
            .padding()
            .preferredColorScheme(.dark)
            .background(Color.black)
    }
}
#endif

