import SwiftUI

struct RecipesView: View {
    
    ///View Data
    @ObservedObject var recipeModel: RecipeModel
    @ObservedObject var groceryModel: GroceryModel
    
    
    @State         var presentAlert: Bool = false
    @State         var gridLayout: [GridItem] = [ GridItem(.adaptive(minimum: 100)), GridItem(.flexible()) ]
    @State         var name: String? = ""
    
    
    @State private var isLoading: Bool
    @State private var searchString: String
    
    init(recipeModel: RecipeModel, groceryModel: GroceryModel) {
        self.recipeModel  = recipeModel
        self.groceryModel = groceryModel
        self.isLoading    = true
        self.searchString = ""
    }
    
    var body: some View {
        
        NavigationStack{
            GeometryReader { geo in
                RefreshableScrollView {
                    
                    /// Search Bar
                    SearchBar(searchString: $searchString)
                    
                    /// If We Are Loading Show The Milk Loading View
                    if ( self.isLoading == true )
                    {
                        MilkLoadingView().frame(width: geo.size.width, height: geo.size.height / 2, alignment: .center)
                    }
                    else
                    {
                        /// If we are not loading show a lazy grid with the information
                        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                            ForEach( $recipeModel.recipes ) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeModel: recipeModel, recipe: recipe))
                                {
                                    GroupBox {
                                        VStack {
                                            Image(uiImage: recipe.image.wrappedValue)
                                                .resizable()
                                                .cornerRadius(5)
                                            
                                            Text(recipe.name.wrappedValue)
                                        }
                                        
                                    }
                                    .frame(width: geo.size.width / 2.2, height: 200)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.all, 10)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Recipes").font(.custom("Futura-Medium", size: 22))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .none, action: {self.presentAlert = true})
                    { Label("Create Recipe", systemImage: "plus.circle")}
                }
            }
        }
        .onChange(of: self.presentAlert) { newValue in
            if( newValue == false && name != "")
            {
                /// Create a new Recipe and save it
                let recipe = Recipe(id: UUID().uuidString, name: name.unsafelyUnwrapped, items: [], addToList: false, recipeType: "", steps: [])
                do { self.isLoading = true; try recipeModel.saveRecipe(recipe: recipe) { _ in
                    self.isLoading = true
                    recipeModel.loadRecipes() { _ in
                        self.isLoading = false
                    }
                }}
                catch { print(error.localizedDescription)}
            }
        }
        .refreshable {
            self.isLoading = true
            recipeModel.loadRecipes() { _ in
                self.isLoading = false
            }
        }
        .textFieldAlert(isPresented: $presentAlert)
        {
            TextFieldAlert(title: "New Recipe", message: "Please enter a new name", text: self.$name)
        }
        .onAppear() {
            self.recipeModel.loadRecipes { _ in
                self.isLoading = false
            }
        }
        

    }
}
