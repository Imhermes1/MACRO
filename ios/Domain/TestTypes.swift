import Foundation

// Test file to verify type accessibility following Apple's Swift guidelines
public struct TestNutrition {
    public let calories: Double
    
    public init(calories: Double) {
        self.calories = calories
    }
}

// Test function to verify compilation
public func testNutritionTypes() -> TestNutrition {
    return TestNutrition(calories: 100.0)
}
