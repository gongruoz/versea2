import SwiftUI

struct Screenshot: View {
    var points: [[Point]]
    var wordsArr: [[String]]
    
    @State private var image: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            // 上半部分：轨迹缩略图容器
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 200)
                
                HStack(spacing: 40) {
                    ForEach(0..<4, id: \.self) { index in
                        if index < points.count {
                            PointsView(points: points[index])
                                .frame(width: 60, height: 120)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // 下半部分：显示单词
            VStack(spacing: 10) {
                ForEach(wordsArr, id: \.self) { wordArray in
                    GridView(words: wordArray)
                        .frame(height: 150)
                        .background(Color.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
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

struct GridView: View {
    var words: [String]
    
    var body: some View {
        let columns = 4
        let rows = Int(ceil(Double(words.count) / 2.0))
        let totalCells = rows * columns
        let positions = Array(0..<totalCells).shuffled().prefix(words.count)
        
        return GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(columns)
            let cellHeight = geometry.size.height / CGFloat(rows)
            
            ZStack {
                ForEach(0..<words.count, id: \.self) { index in
                    let position = positions[index]
                    let x = position % columns
                    let y = position / columns
                    
                    Text(words[index])
                        .foregroundColor(.white)
                        .position(
                            x: CGFloat(x) * cellWidth + cellWidth / 2,
                            y: CGFloat(y) * cellHeight + cellHeight / 2
                        )
                }
            }
        }
    }
}
