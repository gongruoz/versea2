//
//  PointsView.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/3.
//


import SwiftUI

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct PointsView: View {
    var points: [Point]

    var body: some View {
        ZStack {
            ForEach(points, id: \.self) { point in
                Circle()
                    .fill(Color.red) // 点的颜色
                    .frame(width: 10, height: 10)
                    .position(x: CGFloat(point.x) * 20, y: CGFloat(point.y) * 20) // 缩放或调整位置
            }
        }
    }
}


struct WorldPoint: Hashable {
    let x: CGFloat // 使用 CGFloat 以便更精确地控制位置
    let y: CGFloat
    let text: String // 文本属性
}

struct WorldsView: View {
    var points: [WorldPoint]

    var body: some View {
        ZStack {
            ForEach(points, id: \.self) { point in
                VStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(point.text)
                                .foregroundColor(.white)
                                .font(.caption)
                        )
                }
                .position(x: point.x, y: point.y)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 150)
        .background(Color.gray.opacity(0.2))
    }
}



func generateRandomPoints() -> [Point] {
    var points: [Point] = []
    for _ in 0..<5 { // 生成 5 个随机点
        let x = Int.random(in: 0...5) // 随机生成 x 坐标
        let y = Int.random(in: 0...2) // 随机生成 y 坐标
        points.append(Point(x: x, y: y))
    }
    return points
}


func generateWordRandomPoints(wordsArr: [String]) -> [WorldPoint] {
    var points: [WorldPoint] = []
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight: CGFloat = 150 // 设置视图的高度
    let circleDiameter: CGFloat = 50 // 圆的直径
    let minDistance: CGFloat = 60 // 两个圆之间的最小距离

    while points.count < 5 {
        // 随机生成 x 和 y 坐标，确保不会超出边界
        let x = CGFloat.random(in: 0...(screenWidth - circleDiameter))
        let y = CGFloat.random(in: 0...(screenHeight - circleDiameter))

        // 这里替换对应的text 文本 wordsArr【0】根据index取
        let newPoint = WorldPoint(x: x + circleDiameter / 2, y: y + circleDiameter / 2, text: "Point \(points.count + 1)")

        // 检查新生成的点是否与现有点重叠
        if points.allSatisfy({ distance($0, newPoint) > minDistance }) {
            points.append(newPoint)
        }
    }
    return points
}

// 计算两个点之间的距离
func distance(_ point1: WorldPoint, _ point2: WorldPoint) -> CGFloat {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
}
