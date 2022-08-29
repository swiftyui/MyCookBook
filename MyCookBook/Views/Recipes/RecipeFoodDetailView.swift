import SwiftUI
import ConfettiSwiftUI

struct RecipeFoodDetailView: View {
    @Binding var foodItem: FoodItem
    @Binding var recipe: Recipe
    @State var eggs: [Egg] = []
    @State var xPosition: CGFloat = 0
    @State var done: Bool = false
    let timer = Timer.publish(every: 0.5, tolerance: 0.5, on: .main, in: .common).autoconnect()
        
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ForEach(eggs) { egg in
                    EggFalling(xPosition: egg.xPosition, yPositionStart: egg.yPositionStart, yPositionEnd: egg.yPositionEnd)
                }
                .onReceive(timer) { _ in
                    if ( self.eggs.count >= 20)
                    {
                        self.done = true
                    }
                    else
                    {
                        self.xPosition = CGFloat(.random(in: 0...geo.size.width))
                    }

                    if( self.done  == false)
                    {
                        let newEgg = Egg(id: UUID().uuidString, xPosition: self.xPosition, yPositionStart: geo.size.height * -1, yPositionEnd: geo.size.height)
                        self.eggs.insert(newEgg, at: 0)
                    }
                }
                
                ScrollView {
                    GroupBox( label: Label("Basic information", systemImage: "pencil")) {
                        HStack {
                            Text("Item name:").bold()
                            TextField( "Item name", text: $foodItem.name)
                        }
                        
                        HStack {
                            Text("Item quantity:").bold()
                            TextField("Item quantity", value: $foodItem.quantity, formatter: NumberFormatter()).keyboardType(.decimalPad)
                            
                        }
                        
                        Picker(selection: $foodItem.unitType, label: Text("Measurement")) {
                            Text("Units").tag("units")
                            Text("Milligram").tag("mg")
                            Text("Gram").tag("g")
                            Text("Millilitre").tag("ml")
                            Text("Liter").tag("l")
                            Text("Teaspoon").tag("tsp")
                            Text("Tablespoon").tag("tsp")
                            Text("Cup").tag("cup")
                            Text("Slice").tag("slice")
                        }

                    }
                    .shadow(radius: 5)
                    .padding()
                    
                    GroupBox( label: Label("Nutritional information", systemImage: "fork.knife")) {
                        /// Calories
                        HStack { Text("Calories"); TextField("0", value: $foodItem.calories, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Total Fat
                        HStack { Text("Total Fat (g)"); TextField("0", value: $foodItem.totalFat, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Saturated Fat
                        HStack { Text("Protein (g)"); TextField("0", value: $foodItem.protein, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Total Carbohydrates (g)
                        HStack { Text("Carbohydrates (g)"); TextField("0", value: $foodItem.totalCarbohydrates, formatter: NumberFormatter()).keyboardType(.decimalPad) }

                    }
                    .padding()
                    .shadow(radius: 5)
                    
                    
                    GroupBox( label: Label("Vitamin information", systemImage: "pills_fill")) {
                        /// Calories
                        HStack { Text("Vitamin A %"); TextField("0", value: $foodItem.vitaminA, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Total Fat
                        HStack { Text("Vitamin B %"); TextField("0", value: $foodItem.vitaminB, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Saturated Fat
                        HStack { Text("Vitamin C %"); TextField("0", value: $foodItem.vitaminC, formatter: NumberFormatter()).keyboardType(.decimalPad) }
                        /// Total Carbohydrates (g)
                        HStack { Text("Vitamin D %"); TextField("0", value: $foodItem.vitaminD, formatter: NumberFormatter()).keyboardType(.decimalPad) }

                    }
                    .padding()
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                }
            }
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }

        Spacer()
    }
}
