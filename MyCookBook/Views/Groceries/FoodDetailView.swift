import SwiftUI
import ConfettiSwiftUI

struct FoodDetailView: View {
    @Binding var foodItem: FoodItem
    @Binding var groceryList: GroceryList
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


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct Egg: Identifiable {
    var id: String
    var xPosition: CGFloat
    var yPositionStart: CGFloat
    var yPositionEnd: CGFloat
}

struct EggFalling: View {
    @State var moving: Bool = true
    @State var xPosition: CGFloat
    @State var yPositionStart: CGFloat
    @State var yPositionEnd: CGFloat
    @State var counter: Int = 1
    
    
    var body: some View {
        Image("Egg")
            .resizable()
            .frame(width: 30, height: 30, alignment: .center)
            .offset(x: xPosition, y: moving ? yPositionStart: yPositionEnd)
            .onAppear {
                withAnimation(.easeInOut(duration: 5).speed(1).repeatForever(autoreverses: false)) {
                    moving.toggle()
                }
            }
            .confettiCannon(counter: $counter)
            .onTapGesture {
                self.counter += 1
            }
            
        
    }
}
