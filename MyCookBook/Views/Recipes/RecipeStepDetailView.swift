import SwiftUI

struct RecipeStepDetailView: View {
    @Binding var step: CookingSteps
    @State var sliderValue: Float = 0.0
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                Text("Step Number: \(step.stepNumber)").bold()
                
                GroupBox(label: Label("Instructions", systemImage: "highlighter")) {
                    TextEditor(text: $step.stepDescription).cornerRadius(5)
                }
                .padding()
                .shadow(radius: 5)
                
                GroupBox (label: Label("Cooking Time", systemImage: "timer")) {
                    Text(" \(Int(sliderValue)) minutes").padding()
                    Slider(value: $sliderValue, in: 0...60) {
                        Text("Slider")
                    }minimumValueLabel: {
                        Text("0").font(.title2).fontWeight(.thin)
                    } maximumValueLabel: {
                        Text("60").font(.title2).fontWeight(.thin)
                    }
                    .tint(.blue)
                        
                }
                .padding()
                .shadow(radius: 5)
            }
            .onChange(of: sliderValue) { newValue in
                $step.stepTime.wrappedValue = String(newValue)
            }
            .onAppear {
                if($step.stepTime.wrappedValue != "")
                {
                    sliderValue = Float($step.stepTime.wrappedValue).unsafelyUnwrapped
                }
                
            }
        }
    }
}
