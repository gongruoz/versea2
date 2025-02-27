import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlockView: View {
    @ObservedObject var block: Block
    @State private var showScreenshot = false
    @State private var isGlowVisible = false // 控制方块的发光效果
    @State private var isTextVisible = false // 控制文字的透明度
    private let animationDuration: Double = 2.3
    @State private var showGlow = false
    
    // 统一管理动画状态
    private var shouldAnimate: Bool {
        block.isFlashing && block.text != nil && block.text != "" && block.text != " "
    }
    
    var body: some View {
        ZStack {
            if block.isExitButton {
                // Exit button (INFINITY) view
                ZStack {
                    GlowView(isGlowVisible: $showGlow)
                    
                    Circle()
                        .fill(Color.black)
                        .opacity(1)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.white.opacity(0.3), radius: 15, x: 8, y: -8)
                        .shadow(color: Color.white.opacity(0.3), radius: 12, x: 8, y: 8)
                    
                    Text("infinity")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 22))
                }
                .frame(width: 80, height: 80)
                .onTapGesture {
                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedbackGenerator.prepare()
                    impactFeedbackGenerator.impactOccurred()
                    
                    if !RegionManager.shared.orderedPoem.isEmpty {
                        // collect the tapped words on the screen, reorder them, and add them to orderedPoem
                        RegionManager.shared.reorderCurrentPage()
                        

                        showGlow = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showScreenshot = true
                            showGlow = false
                        }
                    } else {
                        // 通知 CanvasView 显示提示
                        NotificationCenter.default.post(name: NSNotification.Name("ShowInfinityAlert"), object: nil)
                    }
                    
                }
            } else {
                // Normal block view
                ZStack {
                    // 基础渐变背景
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

                    // 闪烁动画
                    if shouldAnimate {
                        
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
                            .opacity(isGlowVisible ? 0.3 : 0)
                            .scaleEffect(isGlowVisible ? 1.0 : 0.95)
                    }

                    // 文字显示
                    VStack(spacing: -20) {
                        Text(block.text ?? "")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .font(.custom("IM FELL DW Pica", size: block.isFlashing ? 18 : 22))
                            .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                            .opacity(shouldAnimate ? (isTextVisible ? 0.5 : 0) : 1)
                        
                        // 只在种子方块显示坐标
                        if let coordinateText = block.coordinateText {
                            Text(coordinateText)
                                .font(.custom("IM FELL DW Pica", size: 15))
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                    }
                }
                .clipped()
                .onAppear {
                    // 只在需要动画时启动动画
                    if shouldAnimate {
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            isGlowVisible.toggle()
                            isTextVisible.toggle()
                        }
                    } // removed .repeatForever(autoreverses: true)
                }
                .onChange(of: shouldAnimate) { oldValue, newValue in
                    if newValue { // shouldAnimate 变为 true
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            isGlowVisible.toggle()
                            isTextVisible.toggle()
                        }
                    } else { // shouldAnimate 变为 false
                        isGlowVisible = false
                        isTextVisible = true
                    }
                }
                .onTapGesture {
                    // 排除种子词的点击响应
                    if !block.isSeedPhrase {
                        if block.text != "" && block.text != " " {
                            block.isFlashing.toggle()
                        }
                        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedbackGenerator.prepare()
                        impactFeedbackGenerator.impactOccurred()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showScreenshot) {
            let processedPoints = RegionManager.shared.orderedPoem.map { $0.1.map { Point(x: $0.0, y: $0.1) } }
            let processedWords = RegionManager.shared.orderedPoem.map { $0.2 }
            
            // Add infinity point and word
            let infinityPoint = Point(x: block.position.x, y: block.position.y)
            let finalPoints = processedPoints + [[infinityPoint]]
            let finalWords = processedWords + [["infinity"]]
            
            Screenshot(
                points: finalPoints,
                wordsArr: finalWords,
                onReset: {
                    // 重置所有状态
                    RegionManager.shared.resetAll()
                    CanvasViewModel.shared.reset()
                }
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .padding()
        }
    }
}

