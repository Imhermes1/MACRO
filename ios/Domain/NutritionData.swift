import Foundation

struct NutritionData: Identifiable, Codable {
    let id: String
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let date: Date
    
    init(id: String = UUID().uuidString, name: String, calories: Double, protein: Double, carbs: Double, fat: Double, date: Date = Date()) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
    }
}
