//
//  FoodItemRowView.swift
//  MyCookBook
//
//  Created by Arno van Zyl on 2022/08/30.
//

import SwiftUI

struct FoodItemRowView: View {
    
    @Binding var foodItem: FoodItem
    var body: some View {
        HStack {
            Text(foodItem.name)
        }
    }
}

