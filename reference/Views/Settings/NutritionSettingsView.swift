//
//  NutritionSettingsView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct NutritionSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var calorieGoal: Double
    @State private var proteinGoal: Double = 150
    @State private var carbGoal: Double = 250
    @State private var fatGoal: Double = 65
    @State private var weeklyGoalsEnabled = true
    
    init() {
        let savedGoal = NotificationManager.shared.getCalorieGoal()
        _calorieGoal = State(initialValue: savedGoal > 0 ? savedGoal : 2000.0)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Nutrition Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Set your daily nutrition targets")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Calorie Goal
            VStack(spacing: 16) {
                HStack {
                    Text("Daily Calorie Goal")
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(calorieGoal)) cal")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Slider(value: $calorieGoal, in: 1200...4000, step: 50)
                    .accentColor(.orange)
                    .onChange(of: calorieGoal) { oldValue, newValue in
                        notificationManager.setCalorieGoal(newValue)
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Macro Goals
            VStack(spacing: 16) {
                Text("Macro Goals")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                MacroGoalRow(
                    title: "Protein",
                    value: $proteinGoal,
                    unit: "g",
                    color: .blue,
                    range: 50...300
                )
                
                MacroGoalRow(
                    title: "Carbs",
                    value: $carbGoal,
                    unit: "g",
                    color: .green,
                    range: 100...500
                )
                
                MacroGoalRow(
                    title: "Fat",
                    value: $fatGoal,
                    unit: "g",
                    color: .orange,
                    range: 20...150
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Weekly Goals Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Goals")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Track progress towards weekly targets")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                
                Spacer()
                
                Toggle("", isOn: $weeklyGoalsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

struct MacroGoalRow: View {
    let title: String
    @Binding var value: Double
    let unit: String
    let color: Color
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                Spacer()
                Text("\(Int(value)) \(unit)")
                    .foregroundColor(.white)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            Slider(value: $value, in: range, step: 5)
                .accentColor(color)
        }
    }
}

#Preview {
    NutritionSettingsView()
        .environmentObject(NotificationManager.shared)
} 