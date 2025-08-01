//
//  NotificationManager.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 15/6/2025.
//

import Foundation
@preconcurrency import UserNotifications
import SwiftUI
import Combine

// MARK: - Notification Manager
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager() // Singleton for global access
    
    @Published var isAuthorized: Bool = false
    @Published var reminderTimes: [DateComponents] = [] // Store reminder times
    @Published var isMilestoneNotificationsEnabled: Bool = true
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private let calorieGoalKey = "calorieGoal"
    private let reminderTimesKey = "reminderTimes"
    private let milestoneEnabledKey = "milestoneEnabled"
    
    // MARK: - Initialization
    private init() {
        loadSettings()
        requestAuthorization()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isAuthorized = granted
                if granted {
                    self.scheduleAllReminders()
                    print("Notification permission granted")
                } else if let error = error {
                    print("Notification permission denied: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Settings Management
    func setCalorieGoal(_ goal: Double) {
        userDefaults.set(goal, forKey: calorieGoalKey)
    }
    
    func getCalorieGoal() -> Double {
        return userDefaults.double(forKey: calorieGoalKey)
    }
    
    func setReminderTimes(_ times: [DateComponents]) {
        reminderTimes = times
        userDefaults.set(times.map { [$0.hour ?? 0, $0.minute ?? 0] }, forKey: reminderTimesKey)
        scheduleAllReminders()
    }
    
    func setMilestoneNotifications(_ enabled: Bool) {
        isMilestoneNotificationsEnabled = enabled
        userDefaults.set(enabled, forKey: milestoneEnabledKey)
    }
    
    private func loadSettings() {
        if let savedTimes = userDefaults.array(forKey: reminderTimesKey) as? [[Int]] {
            reminderTimes = savedTimes.map { components in
                var dateComponents = DateComponents()
                dateComponents.hour = components[0]
                dateComponents.minute = components[1]
                return dateComponents
            }
        }
        isMilestoneNotificationsEnabled = userDefaults.bool(forKey: milestoneEnabledKey)
    }
    
    // MARK: - Scheduling
    func scheduleAllReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyMealReminder"])
        
        for (index, time) in reminderTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Meal Reminder"
            content.body = "Time to log your meal! (Reminder \(index + 1))"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "mealReminder"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyMealReminder\(index)", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Failed to schedule reminder \(index): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleMilestoneNotification(currentCalories: Double, goal: Double) {
        guard isMilestoneNotificationsEnabled, let goal = userDefaults.value(forKey: calorieGoalKey) as? Double else { return }
        
        let percentage = (currentCalories / goal) * 100
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        if currentCalories >= goal {
            content.title = "Goal Achieved!"
            content.body = "You've reached your \(Int(goal)) calorie goal with \(Int(currentCalories)) calories!"
        } else if percentage >= 75 {
            content.title = "Milestone Alert"
            content.body = "You're at \(Int(percentage))% of your \(Int(goal)) calorie goal (\(Int(currentCalories)) calories)!"
        } else {
            return // No notification for lower percentages
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Immediate for testing
        let request = UNNotificationRequest(identifier: "milestoneAlert", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule milestone alert: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Scene-Based Presentation (Best Practice)
    func presentNotificationAlert(_ content: UNMutableNotificationContent, trigger: UNNotificationTrigger? = nil, identifier: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else { return }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to present notification alert: \(error.localizedDescription)")
            } else {
                rootVC.present(UNNotificationViewController(content: content), animated: true)
            }
        }
    }
}

// MARK: - Custom Notification View Controller (Optional for Custom UI)
class UNNotificationViewController: UIViewController {
    let content: UNMutableNotificationContent
    
    init(content: UNMutableNotificationContent) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "\(content.title)\n\(content.body)"
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

