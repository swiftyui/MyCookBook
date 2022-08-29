import SwiftUI

struct CookBooksView: View {
    @State var searchString: String = ""
    @State var presentAlert: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                RefreshableScrollView {
                    SearchBar(searchString: $searchString)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Cook Books").font(.custom("Futura-Medium", size: 22))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .none, action: {self.presentAlert = true})
                    { Label("Create Cook Book", systemImage: "plus.circle")}
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
