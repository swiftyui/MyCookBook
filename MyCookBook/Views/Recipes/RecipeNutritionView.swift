import SwiftUI
import Foundation

struct RecipeNutritionView: View {
    @State var recipe: Recipe
    @State var cookingTime: Float = 0
    @State var totalProtein: Double = 0.00
    @State var totalFat: Double = 0.00
    @State var totalCarbs: Double = 0.00
    
    

    var body: some View {
        
        VStack {
            Label("Total Cooking Time: \(Int(cookingTime)) minutes", systemImage: "timer").padding()
            Divider()
            PieChart(title: "Nutritional Breakdown",
                     data: [ChartData(label: "Protein", value: totalProtein),
                            ChartData(label: "Fat", value: totalFat),
                            ChartData(label: "Carbohydrates", value: totalCarbs)], separatorColor: Color(UIColor.systemBackground))
        }
        .onAppear {
            
            /// Get the total cooking time
            for step in recipe.steps {
                if (step.stepTime != "")
                {
                    let time = Float(step.stepTime)
                    cookingTime = cookingTime + time.unsafelyUnwrapped
                }
            }
            
            /// Get the total  protein, fat and carbs
            for item in recipe.items {
                totalProtein += Double(item.protein)
                totalFat += Double(item.totalFat)
                totalCarbs += Double(item.totalCarbohydrates)
            }
        }
    }
}

struct ChartData {
    var label: String
    var value: Double
}

struct PieChartSlice: View {
    
    var center: CGPoint
    var radius: CGFloat
    var startDegree: Double
    var endDegree: Double
    var isTouched:  Bool
    var accentColor:  Color
    var separatorColor: Color
    
    var path: Path {
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startDegree), endAngle: Angle(degrees: endDegree), clockwise: false)
        path.addLine(to: center)
        path.closeSubpath()
        return path
    }
    
    var body: some View {
        path
            .fill(accentColor)
            .overlay(path.stroke(separatorColor, lineWidth: 2))
            .scaleEffect(isTouched ? 1.05 : 1)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func normalizedValue(index: Int, data: [ChartData]) -> Double {
    var total = 0.0
    data.forEach { data in
        total += data.value
    }
    return data[index].value/total
}

struct PieSlice {
     var startDegree: Double
     var endDegree: Double
 }


func angleAtTouchLocation(inPie pieSize: CGRect, touchLocation: CGPoint) ->  Double?  {
     let dx = touchLocation.x - pieSize.midX
     let dy = touchLocation.y - pieSize.midY
     
     let distanceToCenter = (dx * dx + dy * dy).squareRoot()
     let radius = pieSize.width/2
     guard distanceToCenter <= radius else {
         return nil
     }
     let angleAtTouchLocation = Double(atan2(dy, dx) * (180 / .pi))
     if angleAtTouchLocation < 0 {
         return (180 + angleAtTouchLocation) + 180
     } else {
         return angleAtTouchLocation
     }
 }

struct PieChart: View {
    
    var title: String
    var data: [ChartData]
    var separatorColor: Color
    var accentColors: [Color]
    
    @State  private var currentValue = ""
    @State  private var currentLabel = ""
    @State  private var touchLocation: CGPoint = .init(x: -1, y: -1)
    
    //Uncomment the following initializer to use fully generate random colors instead of using a custom color set
    init(title: String, data: [ChartData], separatorColor: Color) {
        self.title = title
        self.data = data
        self.separatorColor = separatorColor

        accentColors    =   [Color]()
        for _  in 0..<data.count  {
           accentColors.append(Color.init(red: Double.random(in: 0.2...0.9), green: Double.random(in: 0.2...0.9), blue: Double.random(in: 0.2...0.9)))
        }
      }
    
    var pieSlices: [PieSlice] {
        var slices = [PieSlice]()
        data.enumerated().forEach {(index, data) in
            let value = normalizedValue(index: index, data: self.data)
            if slices.isEmpty    {
                slices.append((.init(startDegree: 0, endDegree: value * 360)))
            } else {
                slices.append(.init(startDegree: slices.last!.endDegree,    endDegree: (value * 360 + slices.last!.endDegree)))
            }
        }
        return slices
    }
    
    var body: some View {
        VStack {
            Text(title)
            ZStack {
                GeometryReader { geometry in
                    ZStack  {
                        ForEach(0..<self.data.count){ i in
                            PieChartSlice(center: CGPoint(x: geometry.frame(in: .local).midX, y: geometry.frame(in:  .local).midY), radius: geometry.frame(in: .local).width/2, startDegree: pieSlices[i].startDegree, endDegree: pieSlices[i].endDegree, isTouched: sliceIsTouched(index: i, inPie: geometry.frame(in:  .local)), accentColor: accentColors[i], separatorColor: separatorColor)
                        }
                    }
                        .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ position in
                                    let pieSize = geometry.frame(in: .local)
                                    touchLocation   =   position.location
                                    updateCurrentValue(inPie: pieSize)
                                })
                                .onEnded({ _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation(Animation.easeOut) {
                                            resetValues()
                                        }
                                    }
                                })
                        )
                }
                    .aspectRatio(contentMode: .fit)
                VStack  {
                    if !currentLabel.isEmpty   {
                        Text(currentLabel)
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                    }
                    
                    if !currentValue.isEmpty {
                        Text("\(currentValue)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                    }
                }
                .padding()
            }
            VStack(alignment: .leading)  {
                ForEach(0..<data.count)  { i in
                    HStack {
                        accentColors[i].aspectRatio(contentMode: .fit).padding(10)
                        Text(data[i].label)
                        Spacer()
                    }
                }
            }
        }
            .padding()
    }
    
    
    func updateCurrentValue(inPie   pieSize:    CGRect)  {
        guard let angle = angleAtTouchLocation(inPie: pieSize, touchLocation: touchLocation)    else    {return}
        let currentIndex = pieSlices.firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle }) ?? -1
        
        currentLabel = data[currentIndex].label
        currentValue = "\(data[currentIndex].value)"
    }
    
    func resetValues() {
        currentValue = ""
        currentLabel = ""
        touchLocation = .init(x: -1, y: -1)
    }
    
    func sliceIsTouched(index: Int, inPie pieSize: CGRect) -> Bool {
        guard let angle =   angleAtTouchLocation(inPie: pieSize, touchLocation: touchLocation) else { return false }
        return pieSlices.firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle }) == index
    }
    
}
