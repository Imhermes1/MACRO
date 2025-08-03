import Foundation

// Comprehensive NutritionData definition used across all nutrition services
public struct NutritionData: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let brand: String?
    public let calories: Double
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let fiber: Double?
    public let sugar: Double?
    public let sodium: Double?
    public let confidence: Double
    public let source: String
    public let barcode: String?
    public let servingSize: String?
    public let servingUnit: String?
    public let date: Date
    
    // Extended nutrients for world-class accuracy
    public let saturatedFat: Double?
    public let transFat: Double?
    public let cholesterol: Double?
    public let potassium: Double?
    public let calcium: Double?
    public let iron: Double?
    public let vitaminA: Double?
    public let vitaminC: Double?
    public let vitaminD: Double?
    public let vitaminE: Double?
    public let vitaminK: Double?
    public let thiamine: Double?
    public let riboflavin: Double?
    public let niacin: Double?
    public let vitaminB6: Double?
    public let folate: Double?
    public let vitaminB12: Double?
    public let phosphorus: Double?
    public let magnesium: Double?
    public let zinc: Double?
    public let selenium: Double?
    public let copper: Double?
    public let manganese: Double?
    public let chromium: Double?
    public let molybdenum: Double?
    public let chloride: Double?
    
    public init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodium: Double? = nil,
        confidence: Double = 1.0,
        source: String = "manual",
        barcode: String? = nil,
        servingSize: String? = nil,
        servingUnit: String? = nil,
        date: Date = Date(),
        // Extended nutrients
        saturatedFat: Double? = nil,
        transFat: Double? = nil,
        cholesterol: Double? = nil,
        potassium: Double? = nil,
        calcium: Double? = nil,
        iron: Double? = nil,
        vitaminA: Double? = nil,
        vitaminC: Double? = nil,
        vitaminD: Double? = nil,
        vitaminE: Double? = nil,
        vitaminK: Double? = nil,
        thiamine: Double? = nil,
        riboflavin: Double? = nil,
        niacin: Double? = nil,
        vitaminB6: Double? = nil,
        folate: Double? = nil,
        vitaminB12: Double? = nil,
        phosphorus: Double? = nil,
        magnesium: Double? = nil,
        zinc: Double? = nil,
        selenium: Double? = nil,
        copper: Double? = nil,
        manganese: Double? = nil,
        chromium: Double? = nil,
        molybdenum: Double? = nil,
        chloride: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.confidence = confidence
        self.source = source
        self.barcode = barcode
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.date = date
        self.saturatedFat = saturatedFat
        self.transFat = transFat
        self.cholesterol = cholesterol
        self.potassium = potassium
        self.calcium = calcium
        self.iron = iron
        self.vitaminA = vitaminA
        self.vitaminC = vitaminC
        self.vitaminD = vitaminD
        self.vitaminE = vitaminE
        self.vitaminK = vitaminK
        self.thiamine = thiamine
        self.riboflavin = riboflavin
        self.niacin = niacin
        self.vitaminB6 = vitaminB6
        self.folate = folate
        self.vitaminB12 = vitaminB12
        self.phosphorus = phosphorus
        self.magnesium = magnesium
        self.zinc = zinc
        self.selenium = selenium
        self.copper = copper
        self.manganese = manganese
        self.chromium = chromium
        self.molybdenum = molybdenum
        self.chloride = chloride
    }
}

// MARK: - Analysis Result Model

public struct NutritionAnalysisResult {
    public let nutrition: NutritionData
    public let confidence: Double
    public var source: String
    public var analysisMethod: String = ""
    public var analysisTime: TimeInterval = 0.0
    public let suggestions: [String]? // For corrections/improvements
    public let alternatives: [NutritionData]? // Alternative interpretations
    
    public init(nutrition: NutritionData, confidence: Double, source: String, suggestions: [String]? = nil, alternatives: [NutritionData]? = nil) {
        self.nutrition = nutrition
        self.confidence = confidence
        self.source = source
        self.suggestions = suggestions
        self.alternatives = alternatives
    }
}
