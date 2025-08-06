//
//  NutritionProgressView.swift
//  Macro
//
//  Created by Luke Fornieri on 5/8/2025.
//

import SwiftUI
import Combine
import Foundation

/// Modern nutrition progress tracking component
struct NutritionProgressView: View {
    
    // MARK: - Properties
    
    @ObservedObject var trackingService: NutritionTrackingService
    
    private let progressAnimation = Animation.spring(response: 0.8, dampingFraction: 0.8)
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            macroProgressSection
            quickStatsSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            calorieProgressBar
        }
    }
    
    private var calorieProgressBar: some View {
        let progress = min(trackingService.todaysTotals.calories / trackingService.goals.dailyCalories, 1.0)
        let isOverGoal = trackingService.todaysTotals.calories > trackingService.goals.dailyCalories
        
        return VStack(spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(trackingService.todaysTotals.calories))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isOverGoal ? .orange : .primary)
                    
                    Text("of \(Int(trackingService.goals.dailyCalories)) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(trackingService.goals.dailyCalories - trackingService.todaysTotals.calories))")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(isOverGoal ? .orange : .green)
                    
                    Text(isOverGoal ? "over goal" : "remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: isOverGoal ? .orange : .green))
                .animation(progressAnimation, value: progress)
        }
    }
    
    private var macroProgressSection: some View {
        HStack(spacing: 16) {
            MacroProgressCard(
                title: "Protein",
                current: trackingService.todaysTotals.protein,
                goal: trackingService.goals.proteinGrams,
                unit: "g",
                color: .blue,
                icon: "flame.fill"
            )
            
            MacroProgressCard(
                title: "Carbs",
                current: trackingService.todaysTotals.carbs,
                goal: trackingService.goals.carbsGrams,
                unit: "g",
                color: .orange,
                icon: "leaf.fill"
            )
            
            MacroProgressCard(
                title: "Fat",
                current: trackingService.todaysTotals.fat,
                goal: trackingService.goals.fatGrams,
                unit: "g",
                color: .purple,
                icon: "drop.fill"
            )
        }
    }
    
    private var quickStatsSection: some View {
        HStack {
            QuickStatItem(
                title: "Streak",
                value: "\(getCurrentStreak())",
                subtitle: "days",
                icon: "flame",
                color: .orange
            )
            
            Spacer()
            
            QuickStatItem(
                title: "This Week",
                value: "\(getWeeklyAverage())",
                subtitle: "avg cal",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            Spacer()
            
            QuickStatItem(
                title: "Entries",
                value: "\(getTodaysEntryCount())",
                subtitle: "today",
                icon: "list.bullet",
                color: .blue
            )
        }
    }
    
    // MARK: - Helper Views
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        return formatter.string(from: Date())
    }
    
    private func getCurrentStreak() -> Int {
        do {
            return try trackingService.getCurrentStreak()
        } catch {
            return 0
        }
    }
    
    private func getWeeklyAverage() -> Int {
        // Placeholder - would implement proper weekly average calculation
        return Int(trackingService.goals.dailyCalories * 0.9)
    }
    
    private func getTodaysEntryCount() -> Int {
        do {
            return try trackingService.getEntries(for: Date()).count
        } catch {
            return 0
        }
    }
}

// MARK: - Supporting Views

/// Individual macro progress card
struct MacroProgressCard: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    let icon: String
    
    private var progress: Double {
        goal > 0 ? min(current / goal, 1.0) : 0.0
    }
    
    private var isOverGoal: Bool {
        current > goal
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text("\(Int(current))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isOverGoal ? .orange : .primary)
                
                Text("of \(Int(goal))\(unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isOverGoal ? .orange : color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Quick stat item
struct QuickStatItem: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .medium))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
struct NutritionProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let service = NutritionTrackingService()
        
        return ScrollView {
            NutritionProgressView(trackingService: service)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
