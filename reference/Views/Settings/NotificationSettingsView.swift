//
//  NotificationSettingsView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var notificationsEnabled = true
    @State private var breakfastTime = DateComponents(hour: 8, minute: 0)
    @State private var lunchTime = DateComponents(hour: 12, minute: 30)
    @State private var dinnerTime = DateComponents(hour: 18, minute: 0)
    @State private var snackReminder = DateComponents(hour: 15, minute: 0)
    @State private var showingTimePicker = false
    @State private var selectedTimeType: TimeType = .breakfast
    
    enum TimeType: CaseIterable {
        case breakfast, lunch, dinner, snack
        
        var title: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .snack: return "Snack Reminder"
            }
        }
        
        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill"
            case .dinner: return "moon.stars.fill"
            case .snack: return "leaf.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Manage your meal reminders and alerts")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Main Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Notifications")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Receive meal reminders and updates")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                
                Spacer()
                
                Toggle("", isOn: $notificationsEnabled)
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
            
            if notificationsEnabled {
                // Meal Reminders
                VStack(spacing: 16) {
                    Text("Meal Reminders")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(TimeType.allCases, id: \.self) { timeType in
                        mealReminderRow(for: timeType)
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
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(
                timeType: selectedTimeType,
                time: bindingForTimeType(selectedTimeType),
                onDismiss: { showingTimePicker = false }
            )
        }
    }
    
    private func mealReminderRow(for timeType: TimeType) -> some View {
        Button(action: {
            selectedTimeType = timeType
            showingTimePicker = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: timeType.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(timeType.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("Reminder at \(formatTime(for: timeType))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func bindingForTimeType(_ timeType: TimeType) -> Binding<DateComponents> {
        switch timeType {
        case .breakfast: return $breakfastTime
        case .lunch: return $lunchTime
        case .dinner: return $dinnerTime
        case .snack: return $snackReminder
        }
    }
    
    private func formatTime(for timeType: TimeType) -> String {
        let components = timeForType(timeType)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
    
    private func timeForType(_ timeType: TimeType) -> DateComponents {
        switch timeType {
        case .breakfast: return breakfastTime
        case .lunch: return lunchTime
        case .dinner: return dinnerTime
        case .snack: return snackReminder
        }
    }
}

struct TimePickerView: View {
    let timeType: NotificationSettingsView.TimeType
    @Binding var time: DateComponents
    let onDismiss: () -> Void
    
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .onAppear {
                    if let date = Calendar.current.date(from: time) {
                        selectedDate = date
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("\(timeType.title) Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        time = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
                        onDismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(NotificationManager.shared)
} 