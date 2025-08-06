import SwiftUI
import Charts

struct ProgressAnalyticsView: View {
    @StateObject private var profileRepo = UserProfileRepository()
    @State private var selectedTimeframe: TimeFrame = .month
    @State private var showAddWeight = false
    @State private var newWeight = ""
    @State private var newWeightNotes = ""
    
    enum TimeFrame: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case year = "1 Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Analytics Overview Cards
                        if let analytics = profileRepo.getProgressAnalytics() {
                            analyticsOverviewCards(analytics: analytics)
                        }
                        
                        // Weight Chart
                        weightChartSection
                        
                        // Recent Weight Entries
                        recentWeightEntriesSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddWeight = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddWeight) {
                addWeightSheet
            }
        }
    }
    
    private func analyticsOverviewCards(analytics: UserProgressAnalytics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            // Current Weight
            AnalyticsCard(
                title: "Current Weight",
                value: String(format: "%.1f kg", analytics.currentWeight ?? 0),
                subtitle: "Latest entry",
                color: .blue
            )
            
            // Total Change
            if let totalChange = analytics.totalChange {
                AnalyticsCard(
                    title: "Total Change",
                    value: String(format: "%+.1f kg", totalChange),
                    subtitle: "Since start",
                    color: totalChange < 0 ? .green : totalChange > 0 ? .orange : .gray
                )
            }
            
            // Goal Progress
            if let goalProgress = analytics.goalProgressPercent {
                AnalyticsCard(
                    title: "Goal Progress",
                    value: String(format: "%.1f%%", goalProgress),
                    subtitle: "Completed",
                    color: goalProgress >= 100 ? .green : .blue
                )
            }
            
            // BMI
            if let bmi = analytics.currentBMI {
                AnalyticsCard(
                    title: "Current BMI",
                    value: String(format: "%.1f", bmi),
                    subtitle: bmiCategory(bmi),
                    color: bmiColor(bmi)
                )
            }
        }
    }
    
    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weight Trend")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.blue)
            }
            
            let weightData = profileRepo.getWeightTrend(daysBack: selectedTimeframe.days)
            
            if weightData.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("No weight data yet")
                        .foregroundColor(.white.opacity(0.7))
                    Text("Add your first weight entry to see your progress chart")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                )
            } else {
                Chart(weightData) { entry in
                    LineMark(
                        x: .value("Date", entry.recordedAt),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", entry.recordedAt),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(30)
                }
                .frame(height: 200)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, selectedTimeframe.days / 7))) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                )
            }
        }
    }
    
    private var recentWeightEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Entries")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let recentEntries = profileRepo.getRecentWeightEntries(limit: 5)
            
            if recentEntries.isEmpty {
                VStack(spacing: 8) {
                    Text("No weight entries yet")
                        .foregroundColor(.white.opacity(0.7))
                    Text("Tap + to add your first weight entry")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(recentEntries) { entry in
                        WeightEntryRow(entry: entry)
                    }
                }
            }
        }
    }
    
    private var addWeightSheet: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                
                VStack(spacing: 24) {
                    Text("Add Weight Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        TextField("Weight (kg)*", text: $newWeight)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                        
                        TextField("Notes (optional)", text: $newWeightNotes, axis: .vertical)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .lineLimit(3...6)
                    }
                    
                    Button(action: saveWeight) {
                        Text("Save Weight")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                    }
                    .disabled(newWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showAddWeight = false }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func saveWeight() {
        let trimmedWeight = newWeight.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let weight = Float(trimmedWeight.replacingOccurrences(of: ",", with: ".")),
              weight > 0, weight <= 999 else { return }
        
        let notes = newWeightNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        profileRepo.addWeightEntry(
            weight: weight,
            notes: notes.isEmpty ? nil : notes,
            source: "manual"
        )
        
        newWeight = ""
        newWeightNotes = ""
        showAddWeight = false
    }
    
    private func bmiCategory(_ bmi: Float) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    private func bmiColor(_ bmi: Float) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct WeightEntryRow: View {
    let entry: WeightEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.weight, specifier: "%.1f") kg")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(entry.recordedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text(entry.source.capitalized)
                .font(.caption2)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.2))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
}

#Preview {
    ProgressAnalyticsView()
}
