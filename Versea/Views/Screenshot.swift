import SwiftUI

struct Screenshot: View {
    var points: [[Point]]
    var wordsArr: [[String]]
    
    var smallNoise: UIImage = generateNoiseImage(w: 1000, h: 1000, whiten_factor: 0.99, fine_factor: 0.001) ?? UIImage()
    var denseNoise: UIImage = generateNoiseImage(w: 500, h: 500, whiten_factor: 0.99, fine_factor: 0.0001) ?? UIImage()
    
    @State private var image: UIImage?
    
    var body: some View {
        // black background
        
        ZStack { // 外层 ZStack 包裹整个内容
            Color.black // 黑色背景
                .edgesIgnoringSafeArea(.all) // 全屏覆盖
            // add background noise
            Image(uiImage: denseNoise)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .opacity(0.1)
            
            Image(uiImage: smallNoise)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .opacity(0.25)
            
            
            VStack(spacing: 10) {
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
                
                // 固定在底部的按钮
                Button(action: {
                    captureScreenshot()
                }) {
                    Text("Save My Trail")
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 23))
                        .foregroundColor(.white)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(
                                    .shadow(.inner(color: Color.white.opacity(0.12), radius: 12, x: -8, y: -8))
                                    .shadow(.inner(color: Color.white.opacity(0.12), radius: 12, x: 8, y: -8))
                                    .shadow(.inner(color: Color.white.opacity(0.12), radius: 12, x: -8, y: 8))
                                    .shadow(.inner(color: Color.white.opacity(0.12), radius: 12, x: 8, y: 8))
                                )
                                .foregroundColor(.black)
                        )
                }
                .padding(.bottom, 20)  // 底部留出安全距离
            }
        }
        
        
        }
    // 在视图之外建立 function
    private func captureScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            print("Could not find window scene")
            return
        }
        
        DispatchQueue.main.async {
            let bounds = window.bounds
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            
            if let context = UIGraphicsGetCurrentContext() {
                window.layer.render(in: context)
                
                if let image = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
            
            UIGraphicsEndImageContext()
        }
    }
}
