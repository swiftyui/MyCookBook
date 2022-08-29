import SwiftUI
import PhotosUI

struct GroceryDetailView: View {
    @Binding var groceryList: GroceryList
    @EnvironmentObject var groceryModel: GroceryModel
    @Environment(\.presentationMode) var presentationMode
    @State var searchString: String = ""
    @State var isLoading = false
    @State var pickPhoto: Bool = false
    @State var rotateanim  = false
    @State var isAuthorized = false
    
    
    
    
    var body: some View {
        GeometryReader { geo in
            if( isLoading == true)
            {
                MilkLoadingView()                
            }
            else
            {
                if ( pickPhoto == true )
                {
                    ImagePickerView(selectedImage: $groceryList.image, showPopup: $pickPhoto)

                }
                else
                {
                    VStack {
                            
                        ///image
                        Image(uiImage: $groceryList.image.wrappedValue)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 200)
                            .cornerRadius(10)
                            .clipped()
                            .shadow(color: Color.primary.opacity(0.3), radius: 1)
                            .overlay(Color.secondary.cornerRadius(10).opacity(0.6).overlay(Image(systemName: "photo").resizable().frame(width: 30, height: 24).foregroundColor(.white).opacity(0.8).padding(),
                                                                                    alignment: .bottomTrailing))
                            .onTapGesture {
                                self.pickPhoto.toggle()
                            }

                            
                        SearchBar(searchString: $searchString)
                            
                        Button(role: .none, action: {
                            let item = FoodItem(id: UUID().uuidString, name: "New item", quantity: 1, unitType: "g",
                                                calories: 0, totalFat: 0, totalCarbohydrates: 0, protein: 0, vitaminA: 0,
                                                vitaminB: 0, vitaminC: 0, vitaminD: 0)
                            let lastIndex = $groceryList.items.wrappedValue.endIndex
                            $groceryList.items.wrappedValue.insert(item, at: lastIndex)
                        }) { Label("Add item", systemImage: "plus.circle")}
                            
                        List {
                            ForEach($groceryList.items) { item in
                                if( self.searchString.isEmpty ? true : item.name.wrappedValue.lowercased().contains(searchString.lowercased()))
                                {
                                    NavigationLink(destination: FoodDetailView(foodItem: item, groceryList: $groceryList))
                                    { FoodItemRowView(foodItem: item) }
                                    .swipeActions {
                                        Button(role: .destructive, action: { groceryList.items.removeAll( where: {$0.id == item.id }) })
                                        { Label("Delete ingredient", systemImage: "trash") }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField(text: $groceryList.name)
                { Text("Name")}.font(.custom("Futura-Medium", size: 22))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ///save list
                    Button(role: .none, action: {
                        self.isLoading = true
                        groceryModel.updateGroceryList(groceryList: groceryList) { completed in
                            self.isLoading = false
                    }})
                    { Label("Save \($groceryList.name.wrappedValue)", systemImage: "doc.badge.plus")}
                    
                    ///Delete button
                    Button(role: .destructive, action: {
                        self.isLoading = true
                        groceryModel.deleteGroceryList(groceryList: groceryList) { completed in
                            DispatchQueue.main.async {
                                groceryModel.groceryList.removeAll(where: { $0.id == groceryList.id})
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    })
                    { Label("Delete \($groceryList.name.wrappedValue)", systemImage: "trash")}
                    

                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

