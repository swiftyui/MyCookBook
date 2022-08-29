//
//  ImagePickerView.swift
//  MyCookBook
//
//  Created by Arno van Zyl on 2022/09/01.
//

import SwiftUI
import PhotosUI
/// https://developer.apple.com/documentation/photokit/phphotolibrary
struct ImagePickerView: View {
    /// Control variables
    @Binding var selectedImage: UIImage
    @Binding var showPopup: Bool
    @State var authorizationStatus = PHAuthorizationStatus.restricted
    
    
    init(selectedImage: Binding<UIImage>, showPopup: Binding<Bool>) {
        self._selectedImage     = selectedImage
        self._showPopup         = showPopup


    }
        
    var body: some View {
        VStack {
            if ( self.authorizationStatus != PHAuthorizationStatus.authorized )
            {
                VStack {
                    Text( "Photo access denied")
                    Text("You can enable access in Privacy Settings")
                }
                
            }
            else if ( self.authorizationStatus == PHAuthorizationStatus.authorized)
            {
                PhotoPicker(isPresented: $showPopup, selectedImage: $selectedImage)
                
            }
        }
        .onAppear {
            
            /// Get the App's Authorization for the user's library
            let accessLevel          = PHAccessLevel.readWrite
            self.authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        }

    }
}
