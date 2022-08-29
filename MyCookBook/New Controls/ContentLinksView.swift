import SwiftUI

struct ContentLinksView: View {
    
    @Binding var showRecipes:   Bool
    @Binding var showGroceries: Bool
    @Binding var showCookBooks: Bool
    
    var body: some View {
        
        HStack {
            /// Cook Books Quick Link
            GroupBox {
                Image("Book1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64, alignment: .center)
            }
            .padding()
            .onTapGesture {
                self.showCookBooks = true
                self.showGroceries = false
                self.showRecipes   = false
            }
            
            /// Recipes Quick Link
            GroupBox {
                Image("Food1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64, alignment: .center)
            }
            .padding()
            .onTapGesture {
                self.showCookBooks = false
                self.showGroceries = false
                self.showRecipes   = true
            }
            
            /// Grocery Lists Quick Link
            GroupBox {
                Image("Milk")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64, alignment: .center)
            }
            .padding()
            .onTapGesture {
                self.showCookBooks = false
                self.showGroceries = true
                self.showRecipes   = false
            }
        }
    }
}
