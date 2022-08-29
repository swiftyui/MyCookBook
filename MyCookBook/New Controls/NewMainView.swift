import SwiftUI

struct NewMainView: View {
    @ObservedObject var recipeModel: RecipeModel
    @ObservedObject var groceryModel: GroceryModel
    
    @State var showRecipes: Bool
    @State var showCookBooks: Bool
    @State var showGroceries: Bool
    
    
    init(recipeModel: RecipeModel, groceryModel: GroceryModel) {
        self.groceryModel  = groceryModel
        self.recipeModel   = recipeModel
        self.showRecipes   = true
        self.showCookBooks = false
        self.showGroceries = false
    }
    
    var body: some View {
        Text("Nope")
//        RefreshableScrollView {
//            ContentLinksView(showRecipes: $showRecipes, showGroceries: $showGroceries, showCookBooks: $showCookBooks)
//            Divider()
//
//            if( self.showRecipes == true )
//            {
//                RecipesView()
//            }
//            if ( self.showCookBooks == true )
//            {
//                CookBooksView()
//            }
//            if ( self.showGroceries == true )
//            {
//                GroceriesView()
//            }
//            Spacer()
//        }
    }
}
