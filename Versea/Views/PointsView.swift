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
                    .blur(radius: 1)
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
        let positions = Array(0..<totalCells).shuffled().prefix(words.count)
        
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(columns)
            let cellHeight = cellWidth
            let totalHeight = cellHeight * CGFloat(rows)
            
            ZStack {
                ForEach(0..<words.count, id: \.self) { index in
                    let position = positions[index]
                    let x = position % columns
                    let y = position / columns
                    let randOpacity = Double.random(in: 0.1...0.4)
                    
                    RoundedRectangle(cornerRadius: cellHeight / 2, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(randOpacity), Color.white.opacity(0)]),
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
                    
                    Text(words[index])
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .font(.custom("IM FELL DW Pica", size: 18))
                        .frame(width: cellWidth, height: cellHeight)
                        .position(
                            x: CGFloat(x) * cellWidth + cellWidth / 2,
                            y: CGFloat(y) * cellHeight + cellHeight / 2
                        )
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width / CGFloat(columns) * CGFloat(rows))  // 使用屏幕宽度计算高度
    }
}
