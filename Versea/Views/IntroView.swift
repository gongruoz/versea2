import SwiftUI

struct IntroView: View {
    @State private var isIntroComplete = false
    @State private var introOpacity = 0.0
    @State private var showCanvas = false
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    @State private var darkGlowScale: CGFloat = 0 // 黑光初始大小
    @State private var darkGlowOpacity: Double = 0  // 黑光初始透明度
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if showCanvas {
                CanvasView()
                    .transition(.opacity)
                    .animation(.easeIn(duration: 1.0), value: showCanvas)
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Text("Lumino")
                        .font(.custom("IM FELL DW Pica", size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .offset(y: -20)

                    ZStack {
                        // 白光效果
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(glowOpacity), Color.white.opacity(0)]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .padding(5)
                            .blur(radius: 10)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(glowScale)
                        
                        // 黑光效果
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(darkGlowOpacity), Color.clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(darkGlowScale)
                    }
                    .offset(y: -10)

                    Text("a world of many worlds \n a poem of many poems")
                        .font(.custom("IM FELL DW Pica", size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal, 40)
                        .offset(y: 20)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .opacity(introOpacity)
                .ignoresSafeArea()
                .onAppear {
                    // 1. 初始淡入（0-1.2秒）
                    withAnimation(.easeIn(duration: 1.2)) {
                        introOpacity = 1.0
                    }
                    
                    // 2. 白光动画（2.0-2.8秒）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeIn(duration: 0.8)) {
                            glowScale = 25.0
                            glowOpacity = 0.95  // 完全不透明
                        }
                        
                        // 3. 黑光动画（2.8-3.6秒）
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            darkGlowOpacity = 0.6  // 显示黑光
                            withAnimation(.easeOut(duration: 0.5)) {
                                darkGlowScale = 20.0  // 黑光放大
                                glowOpacity = 0.0    // 白光淡出
                            }
                        }
                        
                        // 4. 介绍页面淡出（3.6-4.1秒）
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                introOpacity = 0.0
                            }
                            
                            // 5. 显示主画布
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showCanvas = true
                            }
                        }
                    }
                }
            }
        }
    }
}



struct ContentView: View {
    var body: some View {
        IntroView()
    }
}

