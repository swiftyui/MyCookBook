
import SwiftUI

struct RecipeDetailView: View {
    
    /// View Data
    @ObservedObject var recipeModel: RecipeModel
    @Binding private var recipe: Recipe
    @State private var isLoading: Bool
    @State private var isPresented: Bool
    @State private var showPickPhoto: Bool
    @State var view = ""
    
    
    
    @State var searchString: String = ""
    //    @State var isLoading: Bool = false
    @State var pickPhoto: Bool = false
    
    @State var addToShoppingList: Bool = false
    @State private var isShowingAddToList: Bool = false
    @State var isAuthorized: Bool = false
    
    init(recipeModel: RecipeModel, recipe: Binding<Recipe>) {
        self.recipeModel   = recipeModel
        self._recipe       = recipe
        self.isLoading     = false
        self.isPresented   = false
        self.showPickPhoto = false
    }
    
    
    var body: some View {
        
        GeometryReader { geo in
            
            /// if we are loading show animation
            if ( self.isLoading == true )
            {
                MilkLoadingView()
            }
            else
            {
                /// create the screen layout
                VStack {
                    
                    /// display the recipe image
                    Image(uiImage: recipe.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 200)
                        .cornerRadius(10)
                        .clipped()
                        .shadow(color: Color.primary.opacity(0.3), radius: 1)
                        .overlay(Color.secondary.cornerRadius(10).opacity(0.6).overlay(Image(systemName: "photo").resizable().frame(width: 30, height: 24).foregroundColor(.white).opacity(0.8).padding(),
                                                                                       alignment: .bottomTrailing))
                        .onTapGesture { self.isPresented = true }
                    
                    /// display the picker for the recipe details
                    Picker(selection: $view, label: Text("Details")) {
                        Text("Ingredients").tag("Ingredients")
                        Text("Cooking Steps").tag("Cooking Steps")
                        Text("Details").tag("Details")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    if ( self.view == "Ingredients")
                    {
                        SearchBar(searchString: $searchString)
                        Button(role: .none, action: {
                            let item = FoodItem(id: UUID().uuidString, name: "New item", quantity: 1, unitType: "g", calories: 0, totalFat: 0, totalCarbohydrates: 0,
                                                protein: 0, vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0)
                            let lastIndex = $recipe.items.wrappedValue.endIndex
                            $recipe.items.wrappedValue.insert(item, at: lastIndex)
                        }) { Label("Add ingredient", systemImage: "plus.circle")}
                        
                        List {
                            ForEach($recipe.items) { item in
                                if( self.searchString.isEmpty ? true : item.name.wrappedValue.lowercased().contains(searchString.lowercased()))
                                {
                                    NavigationLink(destination: RecipeFoodDetailView(foodItem: item, recipe: $recipe))
                                    { FoodItemRowView(foodItem: item) }
                                        .swipeActions {
                                            Button(role: .destructive, action: { recipe.items.removeAll( where: {$0.id == item.id }) })
                                            { Label("Delete ingredient", systemImage: "trash") }
                                        }
                                }
                            }
                        }
                    }
                    if ( self.view == "Cooking Steps" )
                    {
                        Button(role: .none, action: {
                            let count = $recipe.steps.wrappedValue.count + 1
                            let step = CookingSteps(id: UUID().uuidString, stepNumber: count, stepDescription: "", stepTime: "")
                            let lastIndex = $recipe.steps.wrappedValue.endIndex
                            $recipe.steps.wrappedValue.insert(step, at: lastIndex)
                        }) { Label("Add step", systemImage: "plus.circle")}
                        
                        
                        List($recipe.steps) { step in
                            NavigationLink(destination: RecipeStepDetailView(step: step))
                            { Text("Step Number: \(step.stepNumber.wrappedValue)") }
                                .swipeActions {
                                    Button(role: .destructive, action: {
                                        recipe.steps.removeAll( where: {$0.id == step.id })
                                        
                                        for index in recipe.steps.indices {
                                            recipe.steps[index].stepNumber = index + 1
                                        }
                                        
                                    })
                                    { Label("Delete step", systemImage: "trash") }
                                }
                        }
                    }
                    if ( self.view == "Details" )
                    {
                        RecipeNutritionView(recipe: recipe)
                    }
                }
                .sheet(isPresented: $isPresented) {
                    ImagePickerView(selectedImage: $recipe.image, showPopup: $isPresented)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField(text: $recipe.name)
                { Text("Name")}.font(.custom("Futura-Medium", size: 22))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    
                    ///Start Cooking
                    NavigationLink(destination: StartCookingView(recipe: recipe))
                    { Label("Start Cooking!", systemImage: "play") }
                    
                    /// Add to Grocery List
                    NavigationLink(destination: AddToShoppingListView(recipe: recipe))
                    { Label("Add to grocery list", systemImage: "cart")}
                                        
                    
                    ///save  Recipe
                    Button(role: .none, action: {
                        self.isLoading = true
                        recipeModel.updateRecipe(recipe: recipe) { _ in
                            self.isLoading = false
                        }})
                    { Label("Save \($recipe.name.wrappedValue)", systemImage: "doc.badge.plus")}
                    
                    ///Delete button
                    Button(role: .destructive, action: {
                        self.isLoading = true
                        recipeModel.deleteRecipe(recipe: recipe) { _ in
                            DispatchQueue.main.async {
                                recipeModel.recipes.removeAll(where: { $0.id == recipe.id})
                            }
                        }
                    })
                    { Label("Delete \($recipe.name.wrappedValue)", systemImage: "trash")}
                    
                    
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}
