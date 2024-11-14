import SwiftUI

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct PointsView: View {
    var points: [Point]
    let gridWidth: CGFloat = UIScreen.main.bounds.width/25
    
    var body: some View {
        ZStack {
            ForEach(points, id: \.self) { point in
                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: gridWidth, height: gridWidth)
                    .opacity(0.9)
//                    .blur(radius: 1)
                    .position(
                        // the x and y are reversed to those of the indices
                        x: CGFloat(point.y) * gridWidth + gridWidth/2,
                        y: CGFloat(point.x) * gridWidth + gridWidth/2
                    )
            }
        }
        .frame(width: gridWidth * 4, height: gridWidth * 8)  // 固定大小，与游戏中的 8x4 网格对应
    }
}


struct GridView: View {
    var words: [String]
    
    var body: some View {
        let columns = 4
        let rows = Int(ceil(Double(words.count) / 2.0))
        let totalCells = rows * columns
        
        // 生成有序的位置数组
        let positions = generateOrderedPositions(totalCells: totalCells, wordCount: words.count)
        
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(columns)
            let cellHeight = cellWidth
            
            ZStack {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    let position = positions[index]
                    let x = position % columns
                    let y = position / columns
                    let randOpacity = Double.random(in: 0.15...0.3)
                    
                    // 背景光晕
                    RoundedRectangle(cornerRadius: cellHeight / 2)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(randOpacity),
                                    Color.white.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: cellHeight * 0.5
                            )
                        )
                        .frame(width: cellWidth, height: cellHeight)
                        .position(
                            x: CGFloat(x) * cellWidth + cellWidth / 2,
                            y: CGFloat(y) * cellHeight + cellHeight / 2
                        )
                    
                    // 文字
                    Text(word)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 20))
                        .frame(width: cellWidth, height: cellHeight)
                        .position(
                            x: CGFloat(x) * cellWidth + cellWidth / 2,
                            y: CGFloat(y) * cellHeight + cellHeight / 2
                        )
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width / CGFloat(columns) * CGFloat(rows))
    }
    
    // 生成有序的位置数组，保持从上到下从左到右的顺序
    private func generateOrderedPositions(totalCells: Int, wordCount: Int) -> [Int] {
        // 1. 创建所有可用位置
        var availablePositions = Array(0..<totalCells)
        
        // 2. 随机选择要使用的位置
        var selectedPositions = [Int]()
        while selectedPositions.count < wordCount && !availablePositions.isEmpty {
            let randomIndex = Int.random(in: 0..<availablePositions.count)
            selectedPositions.append(availablePositions.remove(at: randomIndex))
        }
        
        // 3. 对选中的位置进行排序，确保从上到下从左到右的顺序
        selectedPositions.sort()
        
        return selectedPositions
    }
}
