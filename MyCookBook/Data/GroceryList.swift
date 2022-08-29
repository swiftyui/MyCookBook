import Foundation
import UIKit

struct GroceryList: Identifiable, Hashable, Equatable {
    var id: String
    var name: String
    var items: [FoodItem]
    var addToList: Bool
    var image: UIImage = (UIImage(named: "Food1") ?? UIImage())
}
