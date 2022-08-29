import SwiftUI

@main
struct MyCookBookApp: App {
    ///Application Variables
    @State var groceryModel: GroceryModel = GroceryModel()
    @State var recipeModel: RecipeModel   = RecipeModel()
    
    var body: some Scene {
        WindowGroup {
            
            TabView {
                
                RecipesView(recipeModel: recipeModel, groceryModel: groceryModel).tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                
                GroceriesView(groceryModel: groceryModel).tabItem {
                    Label("Groceries", systemImage: "cart.fill")
                }
                

            }
            
        }
    }
}
