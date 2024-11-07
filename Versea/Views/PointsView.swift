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
                Image("star") // Load star image
                    .resizable()
                    .scaledToFit() // Keep aspect ratio
                    .frame(width: 20, height: 20) // Set image size
                    .position(x: CGFloat(point.x) * 20, y: CGFloat(point.y) * 20) // Scale or adjust position
            }
        }
        .padding(10) // Add padding around the ZStack
        .offset(x: 5, y: 5) // Slight offset to adjust positioning
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
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0)]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
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
