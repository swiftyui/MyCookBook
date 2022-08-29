import Foundation
import UIKit

struct Recipe: Identifiable, Hashable, Equatable {
    var id: String
    var name: String
    var items: [FoodItem]
    var addToList: Bool
    var image: UIImage = (UIImage(named: "Food1") ?? UIImage())
    var recipeType: String
    var steps: [CookingSteps]
}

struct CookingSteps: Identifiable, Hashable, Equatable, Codable {
    var id: String
    var stepNumber: Int
    var stepDescription: String
    var stepTime: String
}
