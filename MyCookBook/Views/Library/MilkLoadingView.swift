
import SwiftUI

struct MilkLoadingView: View {
    @State var rotateanim: Bool = false
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                Text("Loading...").font(.custom("Futura-Medium", size: 22))
                ZStack {
                    Image("Milk2")
                        .font(.system(size: 110))
                        .foregroundColor(.white)
                }
                .rotationEffect(.degrees(rotateanim ? -30 : 35))
                .onAppear() {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    {
                        rotateanim.toggle()
                    }
                    
                }
            }.frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

