import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlockView: View {
    @Binding var word: String
    @ObservedObject var block: Block
    @State private var showScreenshot = false
    @State private var isVisible = false
    @State private var isTextVisible = false
    private let animationDuration: Double = 2.0
    
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
                        .opacity(isVisible ? 0.5 : 0.1)
                        .scaleEffect(isVisible ? 1.0 : 0.95)
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
                    .opacity(block.isFlashing ? (isTextVisible ? 0.5 : 0.1) : 1)
                    .onAppear {
                        if block.isFlashing {
                            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                                isTextVisible.toggle()
                            }
                        } else {
                            isTextVisible = true
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
                let aggregatedPoints = RegionManager.shared.orderedPoem.map { convertToPoints(coordinates: $0.1) }
                let aggregatedWordsArr = RegionManager.shared.orderedPoem.map { $0.2 }
                
                Screenshot(
                    points: aggregatedPoints, // Pass the aggregated points array
                    wordsArr: aggregatedWordsArr // Pass the aggregated wordsArr array
                )
                .padding()
            }
        }
    }
    
    func convertToPoints(coordinates: [(Int, Int)]) -> [Point] {
        return coordinates.map { Point(x: $0.0, y: $0.1) }
    }
    
    
}
