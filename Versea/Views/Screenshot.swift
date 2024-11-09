import SwiftUI
import ScreenshotableView

struct Screenshot: View {
    @Environment(\.dismiss) private var dismiss
    var points: [[Point]]
    var wordsArr: [[String]]
    @State private var shotting = false
    var onReset: () -> Void  // 添加回调函数
    
    var smallNoise: UIImage = generateNoiseImage(w: 1000, h: 1000, whiten_factor: 0.99, fine_factor: 0.001) ?? UIImage()
    var denseNoise: UIImage = generateNoiseImage(w: 500, h: 500, whiten_factor: 0.99, fine_factor: 0.0001) ?? UIImage()
    
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        ScreenshotableScrollView(shotting: $shotting) { screenshot in
            // 保存截图到相册
            UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
            showingSaveConfirmation = true
            
            // 3秒后自动隐藏提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingSaveConfirmation = false
            }
        } content: { style in
            // 主要内容
            ZStack(alignment: .topLeading) {
                Color.black
                    .ignoresSafeArea()
                
                // Dense noise layer
                GeometryReader { geometry in
                    Image(uiImage: denseNoise)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .clipped()
                        .opacity(0.1)
                        .ignoresSafeArea()
                }
                
                // Small noise layer
                GeometryReader { geometry in
                    Image(uiImage: smallNoise)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .clipped()
                        .opacity(0.25)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 10) {
                    // 根据状态调整顶部间距
                    Spacer()
                        .frame(height: style == .inView ? 60 : 30)
                    
                    // 上半部分：轨迹缩略图容器
                    ZStack {
                        Rectangle()
                            .frame(height: UIScreen.main.bounds.width * 0.4)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 12, x: -8, y: -8))  // 左上角高光
                                    .shadow(.inner(color: Color.white.opacity(0.04), radius: 12, x: 8, y: -8))   // 右上角高光
                                    .shadow(.inner(color: Color.white.opacity(0.08), radius: 12, x: -8, y: 8))   // 左下角高光
                                    .shadow(.inner(color: Color.white.opacity(0.04), radius: 12, x: 8, y: 8))    // 右下角高光
                                
                            )
                            .foregroundColor(.black)
                            .frame(height: UIScreen.main.bounds.width * 0.4 + 4)
                        
                        
                        
                        //                        .stroke(Color.white.opacity(0.4), lineWidth: 3) // 边缘白色，调整opacity达到预期效果
                        //                        .blur(radius: 3.5) // 适当模糊以获得柔和的内阴影效果
                        //                        .offset(x: -1, y: -1)  // 微调偏移以模拟内阴影
                        
                        
                        
                        HStack(spacing: 15) {
                            ForEach(0..<4, id: \.self) { index in
                                if index < points.count {
                                    PointsView(points: points[index])
                                }
                            }
                        }
                    }.padding(25)
                    
                    // 下半部分：显示单词
                    VStack(spacing: 2) {
                        ForEach(wordsArr, id: \.self) { wordArray in
                            GridView(words: wordArray)
                        }
                    }
                    .padding(8)
                    
                    // 只在非截图状态下显示按钮
                    if style == .inView {
                        VStack(spacing: 10) {
                            // 截图按钮
                            Button(action: {
                                shotting.toggle()  // 触发截图
                            }) {
                                Text("save my trail")
                                    .multilineTextAlignment(.center)
                                    .font(.custom("IM FELL DW Pica", size: 18))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                                            .fill(
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: -5, y: -5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: 5, y: -5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: -5, y: 5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: 5, y: 5))
                                            )
                                            .foregroundColor(.black)
                                    )
                            }
                            .padding(.vertical, 10)
                            
                            // 返回按钮
                            Button(action: {
                                dismiss()
                                onReset()  // 调用回调函数
                            }) {
                                Text("back to the maze")
                                    .multilineTextAlignment(.center)
                                    .font(.custom("IM FELL DW Pica", size: 18))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                                            .fill(
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: -5, y: -5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: 5, y: -5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: -5, y: 5))
                                                .shadow(.inner(color: Color.white.opacity(0.08), radius: 8, x: 5, y: 5))
                                            )
                                            .foregroundColor(.black)
                                    )
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    
                    // 在截图状态下显示水印
                    if style == .inScreenshot {
                        HStack {
                            Spacer()
                            Text("by a devcon poet \n via Lumino")
                                .font(.custom("IM FELL DW Pica", size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 20)
                        }
                    }
                    
                    // 根据状态调整底部间距
//                    Spacer()
//                        .frame(height: 30)
                }
            }
            
//            // 显示保存成功提示
//            if showingSaveConfirmation {
//                ZStack {
//                    // 半透明黑色背景
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.black.opacity(0.4))
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    
//                    // 提示文本
//                    Text("Screenshot saved")
//                        .font(.custom("IM FELL DW Pica", size: 24))
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.white)
//                        .padding()
//                        .transition(.opacity)
//                        .animation(.easeInOut, value: showingSaveConfirmation)
//                }
//                .ignoresSafeArea()
//            }
        }
        .background(Color.black)
        .frame(width: UIScreen.main.bounds.width)
    }
}
