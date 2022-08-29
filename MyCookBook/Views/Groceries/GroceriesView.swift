import SwiftUI
import simd

struct GroceriesView: View {
    
    ///View Variables
    @ObservedObject var groceryModel: GroceryModel
    @State private var searchString: String
    @State private var isLoading: Bool
    @State private var presentAlert: Bool
    @State private var gridLayout: [GridItem]
    

    @State var name: String? = "" ///TODO clean this
    
    
    init(groceryModel: GroceryModel) {
        self.groceryModel = groceryModel
        self.searchString = ""
        self.isLoading    = true
        self.presentAlert = false
        self.gridLayout   = [ GridItem(.adaptive(minimum: 100)), GridItem(.flexible()) ]
    }
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                RefreshableScrollView {
                    SearchBar(searchString: $searchString)
                    if( self.isLoading == true )
                    {
                        MilkLoadingView().frame(width: geo.size.width, height: geo.size.height / 2, alignment: .center)
                    }
                    else
                    {
                        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                            ForEach($groceryModel.groceryList.filter { self.searchString.isEmpty ? true : $0.name.wrappedValue.lowercased().contains(searchString.lowercased())}) { list in
                                NavigationLink(destination: GroceryDetailView(groceryList: list).environmentObject(groceryModel))
                                {
                                    GroupBox {
                                        VStack {
                                            Image(uiImage: list.image.wrappedValue)
                                                .resizable()
                                                .cornerRadius(5)
                                                
                                            Text(list.name.wrappedValue)
                                        }
                                        
                                    }
                                    .frame(width: geo.size.width / 2.2, height: 200)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.all, 10)
                        .animation(.easeIn, value: gridLayout.count)
                    }
                }
            }
            .onChange(of: self.presentAlert) { newValue in
                if( newValue == false && name != "")
                {
                    ///create a new grocery list  and save it
                    let groceryList = GroceryList(id: UUID().uuidString, name: self.name.unsafelyUnwrapped, items: [], addToList: false)
                    groceryModel.saveGroceryList(groceryList: groceryList) { completed in
                        self.name = ""
                        groceryModel.loadGroceryLists { completed in
                            groceryModel.toggleLoading()
                        }
                        
                    }
                }
            }
            .textFieldAlert(isPresented: $presentAlert)
            {
                TextFieldAlert(title: "New Grocery List", message: "Please enter a new name", text: self.$name)
            }
            .refreshable {
                self.isLoading = true
                self.groceryModel.loadGroceryLists { _ in
                    self.isLoading = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Grocery Lists").font(.custom("Futura-Medium", size: 22))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .none, action: {self.presentAlert = true})
                    { Label("Create Grocery list", systemImage: "plus.circle")}
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

