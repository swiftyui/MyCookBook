import SwiftUI

struct StartCookingView: View {
    
    /// View Variables
    @State   private var recipe: Recipe
    @State   private var step: CookingSteps
    @State   private var currentStep: Int
    
    init(recipe: Recipe) {
        self.recipe       = recipe
        self.currentStep  = 1
        self.step         = CookingSteps(id: "", stepNumber: 1, stepDescription: "", stepTime: "")
    }
    
    
    var body: some View {
        
        if(self.currentStep > recipe.steps.count)
        {
            Button(role: .none, action: { })
            { Label("All done!", systemImage: "balloon.2.fill")}.padding()
        }
        else
        {
            VStack {
                HStack(alignment: .center) {
                    Text("Step number \(currentStep)").font(.custom("Futura-Medium", size: 22))
                }
                
                Text(step.stepDescription).padding()
                
                Spacer()
                Button(role: .none, action: {currentStep += 1})
                { Label("Finish step", systemImage: "checkmark.seal.fill")}.padding()
                
            }
            .onAppear { step = recipe.steps.first(where: {$0.stepNumber == currentStep})! }
        }
    }
}
