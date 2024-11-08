import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlockView: View {
    @Binding var word: String
    @ObservedObject var block: Block
    @State private var showScreenshot = false
    @State private var isVisible = false
    @State private var isTextVisible = false
    private let animationDuration: Double = 3.5
    @State private var showGlow = false
    
    var body: some View {
        ZStack {
            if block.isExitButton {
                // Exit button (INFINITY) view
                ZStack {
                    GlowView(isVisible: $showGlow)
                    
                    Circle()
                        .fill(Color.black)
                        .opacity(1)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.white.opacity(0.12), radius: 10, x: 8, y: -8)
                        .shadow(color: Color.white.opacity(0.12), radius: 8, x: 8, y: 8)
                    
                    Text("INFINITY")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 18))
                }
                .frame(width: 80, height: 80)
                .onTapGesture {
                    if !RegionManager.shared.orderedPoem.isEmpty {
                        showGlow = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showScreenshot = true
                            showGlow = false
                        }
                    }
                }
            } else {
                // Normal block view
                ZStack {
                    if !block.isFlashing {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
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
                                    gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0)]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .padding(3)
                            .opacity(isVisible ? 0.3 : 0)
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
                        .opacity(block.isFlashing ? (isTextVisible ? 0.5 : 0) : 1)
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
                .clipped()
                .onTapGesture {
                    if block.text != "" {
                        block.isFlashing.toggle()
                    }
                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedbackGenerator.prepare()
                    impactFeedbackGenerator.impactOccurred()
                }
            }
        }
        .sheet(isPresented: $showScreenshot) {
            ScrollView {
                Screenshot(
                    points: RegionManager.shared.orderedPoem.map { $0.1.map { Point(x: $0.0, y: $0.1) } },
                    wordsArr: RegionManager.shared.orderedPoem.map { $0.2 }
                )
                .padding()
            }
        }
    }
}
