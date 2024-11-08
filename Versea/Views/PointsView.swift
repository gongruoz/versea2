import SwiftUI

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct PointsView: View {
    var points: [Point]
    let gridWidth: CGFloat = 7.5  // 使用固定的网格宽度
    
    var body: some View {
        ZStack {
            ForEach(points, id: \.self) { point in
                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: gridWidth, height: gridWidth)
                    .opacity(0.6)
                    .blur(radius: 1)
                    .position(
                        x: CGFloat(point.x) * gridWidth + gridWidth/2,
                        y: CGFloat(point.y) * gridWidth + gridWidth/2
                    )
            }
        }
        .frame(width: gridWidth * 8, height: gridWidth * 4)  // 固定大小，与游戏中的 8x4 网格对应
    }
}

// 可选：添加网格背景
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // 绘制网格线
                // ...
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        }
    }
}

struct WorldPoint: Hashable {
    let x: CGFloat // Use CGFloat for precise control
    let y: CGFloat
    let text: String // Text attribute
}

struct WorldsView: View {
    var points: [WorldPoint]

    var body: some View {
        ZStack {
            Color.black
            
            ForEach(points, id: \.self) { point in
                VStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .padding(3) // Add padding inside each rectangle
                        .blur(radius: 3)
                }
                .position(x: point.x, y: point.y)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 150)
        .background(Color.gray.opacity(0.02))
        .padding(15) // Add outer padding to the whole ZStack
        .offset(x: -10, y: 10) // Slight offset to adjust positioning
    }
}
