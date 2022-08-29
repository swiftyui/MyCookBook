import Foundation
import UIKit

struct FoodItem: Identifiable, Codable, Hashable, Equatable {
    var id: String
    var name: String
    var quantity: Int
    var unitType: String
    var calories: Float
    var totalFat: Float
    var totalCarbohydrates: Float
    var protein: Float
    var vitaminA: Float
    var vitaminB: Float
    var vitaminC: Float
    var vitaminD: Float
    
    init(id: String, name: String, quantity: Int, unitType: String, calories: Float, totalFat: Float, totalCarbohydrates: Float, protein: Float, vitaminA: Float, vitaminB: Float, vitaminC: Float, vitaminD: Float) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitType = unitType
        self.calories = calories
        self.totalFat = totalFat
        self.totalCarbohydrates = totalCarbohydrates
        self.protein = protein
        self.vitaminA = vitaminA
        self.vitaminB = vitaminB
        self.vitaminC = vitaminC
        self.vitaminD = vitaminD
        
    }
}

