import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlockView: View {
    @Binding var word: String
    @ObservedObject var block: Block
    @State private var showScreenshot = false
    @State private var isVisible = false
    @State private var isTextVisible = false
    private let animationDuration: Double = 2.3
    @State private var showGlow = false
    
    // 统一管理动画状态
    private var shouldAnimate: Bool {
        block.isFlashing && block.text != nil && !block.text!.isEmpty && block.text != " "
    }
    
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
                        .shadow(color: Color.white.opacity(0.2), radius: 10, x: 8, y: -8)
                        .shadow(color: Color.white.opacity(0.2), radius: 8, x: 8, y: 8)
                    
                    Text("INFINITY")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 18))
                }
                .frame(width: 80, height: 80)
                .onTapGesture {
                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedbackGenerator.prepare()
                    impactFeedbackGenerator.impactOccurred()
                    if !RegionManager.shared.orderedPoem.isEmpty {
                        // 添加 INFINITY 到 orderedPoem
                        RegionManager.shared.addInfinityToPoem(block: block)
                        
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
                            .opacity(isVisible ? 0.3 : 0)
                            .scaleEffect(isVisible ? 1.0 : 0.95)
                    }

                    // 文字显示
                    VStack(spacing: -20) {
                        Text(word)
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
                            isVisible.toggle()
                            isTextVisible.toggle()
                        }
                    } // removed .repeatForever(autoreverses: true)
                }
                .onChange(of: shouldAnimate) { oldValue, newValue in
                    if newValue {
                        withAnimation(Animation.easeInOut(duration: animationDuration)) {
                            isVisible.toggle()
                            isTextVisible.toggle()
                        }
                    } else {
                        isVisible = false
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
            Screenshot(
                points: RegionManager.shared.orderedPoem.map { $0.1.map { Point(x: $0.0, y: $0.1) } },
                wordsArr: RegionManager.shared.orderedPoem.map { $0.2 },
                onReset: {
                    // 重置所有状态
                    RegionManager.shared.resetAll()  // 需要在 RegionManager 中添加这个方法
                    CanvasViewModel.shared.reset()   // 需要在 CanvasViewModel 中添加这个方法
                }
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .padding()
        }
    }
}
