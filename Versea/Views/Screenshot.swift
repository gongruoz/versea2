import SwiftUI

struct Screenshot: View {
    var points: [[Point]]
    var wordsArr: [[String]]
    
    @State private var image: UIImage?
    
    var body: some View {
        Color.black
        VStack(spacing: 10) {
            // 上半部分：轨迹缩略图容器
            ZStack {
                Rectangle()
                    .fill(Color.gray).opacity(0.2)
                    .frame(height: UIScreen.main.bounds.width/2)
                
                HStack(spacing: 15) {
                    ForEach(0..<4, id: \.self) { index in
                        if index < points.count {
                            PointsView(points: points[index])
//                                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5*2)
                        }
                    }
                }
            }
//            .padding(.horizontal)
            
            // 下半部分：显示单词
            VStack(spacing: 2) {
                ForEach(wordsArr, id: \.self) { wordArray in
                    GridView(words: wordArray)
                        .background(Color.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(2)
            
            Button(action: {
                captureScreenshot()
            }) {
                Text("Save to Photos")
                    .foregroundColor(.blue)
            }
        }
    }
    
    func captureScreenshot() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(bounds: window?.bounds ?? CGRect.zero)
        
        let screenshot = renderer.image { context in
            window?.layer.render(in: context.cgContext)
        }

        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
    }
}
