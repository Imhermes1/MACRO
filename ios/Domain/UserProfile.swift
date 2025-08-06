// This is the canonical UserProfile model. Do not redefine elsewhere.
import Foundation

public struct UserProfile: Codable, Identifiable, Sendable {
    public let id: String
    public var firstName: String
    public var lastName: String?
    public var age: Int
    public var dob: String?
    public var height: Float // in cm
    public var weight: Float // current weight in kg
    public var initialWeight: Float? // starting weight for progress tracking
    public var goalWeight: Float? // target weight
    public var goalType: GoalType
    public var activityLevel: ActivityLevel
    public var profileCompleted: Bool
    
    // Add initializer that creates a UUID for new profiles
    public init(
        firstName: String, 
        lastName: String? = nil, 
        age: Int, 
        dob: String? = nil, 
        height: Float, 
        weight: Float, 
        initialWeight: Float? = nil,
        goalWeight: Float? = nil,
        goalType: GoalType = .maintainWeight,
        activityLevel: ActivityLevel = .moderate,
        profileCompleted: Bool = false,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.dob = dob
        self.height = height
        self.weight = weight
        self.initialWeight = initialWeight ?? weight // Default initial weight to current weight
        self.goalWeight = goalWeight
        self.goalType = goalType
        self.activityLevel = activityLevel
        self.profileCompleted = profileCompleted
    }
    
    // Add CodingKeys for proper JSON serialization with Supabase
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case age
        case dob = "date_of_birth"
        case height
        case weight
        case initialWeight = "initial_weight"
        case goalWeight = "goal_weight"
        case goalType = "goal_type"
        case activityLevel = "activity_level"
        case profileCompleted = "profile_completed"
    }
}

// Goal types for weight management
public enum GoalType: String, CaseIterable, Codable {
    case loseWeight = "lose_weight"
    case gainWeight = "gain_weight"
    case maintainWeight = "maintain_weight"
    case buildMuscle = "build_muscle"
    
    public var displayName: String {
        switch self {
        case .loseWeight: return "Lose Weight"
        case .gainWeight: return "Gain Weight"
        case .maintainWeight: return "Maintain Weight"
        case .buildMuscle: return "Build Muscle"
        }
    }
}

// Activity levels for calorie calculations
public enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    public var displayName: String {
        switch self {
        case .sedentary: return "Sedentary (little/no exercise)"
        case .light: return "Light (1-3 days/week)"
        case .moderate: return "Moderate (3-5 days/week)"
        case .active: return "Active (6-7 days/week)"
        case .veryActive: return "Very Active (2x/day, intense)"
        }
    }
    
    public var multiplier: Float {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

// Weight history entry for tracking changes over time
public struct WeightEntry: Codable, Identifiable {
    public let id: String
    public let userId: String
    public var weight: Float
    public var recordedAt: Date
    public var notes: String?
    public var source: String
    
    public init(
        userId: String,
        weight: Float,
        recordedAt: Date = Date(),
        notes: String? = nil,
        source: String = "manual",
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.userId = userId
        self.weight = weight
        self.recordedAt = recordedAt
        self.notes = notes
        self.source = source
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weight
        case recordedAt = "recorded_at"
        case notes
        case source
    }
}

// Analytics data structure
public struct UserProgressAnalytics: Codable {
    public let currentWeight: Float?
    public let initialWeight: Float?
    public let goalWeight: Float?
    public let totalChange: Float?
    public let goalProgressPercent: Float?
    public let avgWeeklyChange: Float?
    public let daysTracking: Int
    public let totalEntries: Int
    public let currentBMI: Float?
    
    enum CodingKeys: String, CodingKey {
        case currentWeight = "current_weight"
        case initialWeight = "initial_weight"
        case goalWeight = "goal_weight"
        case totalChange = "total_change"
        case goalProgressPercent = "goal_progress_percent"
        case avgWeeklyChange = "avg_weekly_change"
        case daysTracking = "days_tracking"
        case totalEntries = "total_entries"
        case currentBMI = "current_bmi"
    }
}
