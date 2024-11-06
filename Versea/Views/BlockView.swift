import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlockView: View {
    @Binding var word: String
    var onChange: ((String, Color) -> Void)?
    @ObservedObject var block: Block
    @State private var isVisible = false // Control opacity of shimmer behind flashing texts
    @State private var isTextVisible = false // State variable to control opacity of text
    @State private var animationDuration: Double = Double.random(in: 3...4)
    @State private var showScreenshot = false // State variable to show screenshot modal

    var body: some View {
        ZStack {
            if block.isExitButton {
                // Customize appearance for the exit button block
                Text("Exit")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .font(.custom("IM FELL DW Pica", size: 18))
                    .onTapGesture {
                        showScreenshot = true // Show the screenshot modal
                    }
            } else {
                if !block.isFlashing {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .padding(3)
                        .blur(radius: 8)
                }

                if block.isFlashing && block.text != "" {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .padding(3)
                        .opacity(isVisible ? 0.5 : 0.1) // Animation target
                        .scaleEffect(isVisible ? 1.0 : 0.95) // Slight scaling effect to enhance the animation
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                                isVisible.toggle()
                            }
                        }
                }

                Text(word)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .font(.custom("IM FELL DW Pica", size: block.isFlashing ? 18 : 24))
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                    .opacity(block.isFlashing ? (isTextVisible ? 0.5 : 0.1) : 1) // Use 1 opacity when not flashing
                    .scaleEffect(block.isFlashing ? (isTextVisible ? 1.0 : 0.95) : 1.0) // Scale effect only when flashing
                    .onAppear {
                        if block.isFlashing {
                            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                                isTextVisible.toggle()
                            }
                        } else {
                            isTextVisible = true // Ensure isTextVisible is true when not flashing to show it fully
                        }
                    }
            }
        }
        .clipped()
        .onTapGesture {
            if block.text != "" {
                block.isFlashing.toggle()
            }
        }
        // Present Screenshot view as a sheet when showScreenshot is true
        .sheet(isPresented: $showScreenshot) {
            ScrollView {
                Screenshot(points: generatePoints(), wordsArr: generateWordsArray())
            }
        }
    }
    
    // Helper functions to be removed later
    func generatePoints() -> [[Point]] {
        // Example function to generate points, customize as needed
        [generateRandomPoints(), generateRandomPoints(), generateRandomPoints(), generateRandomPoints()]
    }
    
    func generateWordsArray() -> [String] {
        // Example function to generate words array, customize as needed
        ["Hello", "SwiftUI", "Screenshot", "Test"]
    }
}
