import UIKit
import SwiftUI
import Foundation

struct SearchBar: UIViewRepresentable {
    
    @Binding var searchString: String

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchString
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $searchString)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var searchString: String
        
        init(text: Binding<String>) {
            _searchString = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           searchString = searchText
        }
    }
}
