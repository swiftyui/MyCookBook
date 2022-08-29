import SwiftUI

struct AddToShoppingListView: View {
    /// View variables
    @ObservedObject var groceryModel: GroceryModel
    @State private var recipe: Recipe
    @State private var isLoading: Bool
    
    
    init(recipe: Recipe) {
        /// Init variables
        self.recipe       = recipe
        self.groceryModel = GroceryModel()
        self.isLoading    = true
     }


    var body: some View {
        
        VStack {
            if( self.isLoading == true )
            {
                MilkLoadingView()
            }
            else
            {
                if(groceryModel.groceryList.count == 0 )
                {
                    Text("No grocery lists!")
                }
                else
                {
                    List {
                        ForEach( $groceryModel.groceryList ) { list in
                            HStack {
                                CheckBoxView(checked: list.addToList )
                                Text(list.name.wrappedValue)
                            }
                            
                        }
                    }
                    .refreshable {
                        self.isLoading = true
                        self.groceryModel.loadGroceryLists { _ in
                            self.isLoading = false
                        }
                    }
                    Button(role: .none, action: {
                        
                        groceryModel.isLoading = true
                        
                        for list in $groceryModel.groceryList {
                            if(list.addToList.wrappedValue == true)
                            {
                                for recipeItem in recipe.items {
                                    let newItem = FoodItem(id: recipeItem.id, name: recipeItem.name, quantity: recipeItem.quantity,
                                                           unitType: recipeItem.unitType, calories: recipeItem.calories, totalFat: recipeItem.totalFat,
                                                           totalCarbohydrates: recipeItem.totalCarbohydrates, protein: recipeItem.protein,
                                                           vitaminA: recipeItem.vitaminA, vitaminB: recipeItem.vitaminB, vitaminC: recipeItem.vitaminC, vitaminD: recipeItem.vitaminD)
                                    let lastIndex = list.items.wrappedValue.endIndex
                                    list.items.wrappedValue.insert(newItem, at: lastIndex)
                                }
                                
                                ///once all items are processed save
                                groceryModel.updateGroceryList(groceryList: list.wrappedValue) { _ in
                                }
                            }
                        }
                        
                        groceryModel.isLoading = false                        
                        
                    })
                    { Label("Add to grocery list", systemImage: "cart.badge.plus")}
                    
                }
            }
        }
        .onAppear() {
            self.groceryModel.loadGroceryLists { _ in
                self.isLoading = false
                
            }
        }
    }
}
