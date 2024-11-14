import SwiftUI

struct CanvasView: View {
    // Tutorial messages
    let tutorialMessages = [
        
//        """
//        tap some words
//        and SHAKE your phone!
//        """,
//        "",
//        
        
        """
        find infinity to exit
        """
    ]
    
    @State private var currentMessageIndex = 0
    @State private var isTutorialComplete = false
    @ObservedObject var regionManager = RegionManager.shared
    @State private var showInfinityAlert = false
    @State private var showSelectWordsAlert = false
    @State private var isButtonPressed = false
    
    var body: some View {
        ZStack {
            // Main content
            Infinite4Pager(
                initialHorizontalPage: 3,
                initialVerticalPage: 3,
                totalHorizontalPage: nil,
                totalVerticalPage: nil,
                enableClipped: false,
                enablePageVisibility: false,
                getPage: { h, v in
                    PageView(h: h, v: v)
                }
            )
            .ignoresSafeArea()
            .onAppear {
                // 设置初始位置为 0-0
                CanvasViewModel.shared.updateCurrentMainPage(horizontal: 0, vertical: 0)
            }
            
            // Tutorial Overlay
            if !isTutorialComplete {
                Text(tutorialMessages[currentMessageIndex])
                    .font(.custom("IM FELL DW Pica", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                            .blur(radius: 10)

                    )
                    .onAppear {
                        startTutorial()
                    }
            }
            
            // Top status bar with indicators
            VStack {
                HStack {
                    // New position indicator
                    LocationIndicator(currentPage: CanvasViewModel.shared.currentMainPage)
                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    // Existing line breaks counter
                    Text("\(regionManager.orderedPoem.count) \(regionManager.orderedPoem.count <= 1 ? "line" : "lines") of poem")
                        .font(.custom("IM FELL DW Pica", size: 15))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.4))
                                .blur(radius: 3)
                        )
                        .padding(.top, 15)
                        .padding(.trailing, 15)
                }
                
                Spacer()
                
                // Modified reorder button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Check if any words are selected
                        let currentPageIndex = CanvasViewModel.shared.getIndex(
                            h: CanvasViewModel.shared.currentMainPage?.horizontal ?? 0,
                            v: CanvasViewModel.shared.currentMainPage?.vertical ?? 0
                        )
                        
                        if let blocks = regionManager.allBlocks[currentPageIndex],
                           blocks.contains(where: { !$0.isFlashing && !$0.isSeedPhrase && $0.text != nil && !$0.text!.isEmpty }) {
                            // Words are selected, perform reorder
                            regionManager.reorderCurrentPage()
                            
                            // Add haptic feedback
                            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                            impactFeedbackGenerator.prepare()
                            impactFeedbackGenerator.impactOccurred()
                        } else {
                            // No words selected, show alert
                            showSelectWordsAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSelectWordsAlert = false
                            }
                        }
                    }) {
                        Triangle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 25, height: 20)
                            .scaleEffect(isButtonPressed ? 0.9 : 1.0)
                    }
                    .pressEvents {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isButtonPressed = true
                        }
                    } onRelease: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isButtonPressed = false
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
                }
            }
            
            // Infinity alert
            if showInfinityAlert {
                Text("tap words and shake to unlock infinity!")
                    .font(.custom("IM FELL DW Pica", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                            .blur(radius: 10)
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: showInfinityAlert)
            }

            // Select words alert
            if showSelectWordsAlert {
                Text("select some words")
                    .font(.custom("IM FELL DW Pica", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                            .blur(radius: 10)
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: showSelectWordsAlert)
            }
        }
        .onAppear {
            // 合并现有的 onAppear 代码
            regionManager.startAutoFlashing()
            
            // 设置初始位置为 0-0
            CanvasViewModel.shared.updateCurrentMainPage(horizontal: 0, vertical: 0)
            
            // 添加通知监听
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowInfinityAlert"), object: nil, queue: .main) { _ in
                showInfinityAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showInfinityAlert = false
                }
            }
        }
        
    }
    
    // Timer to iterate through tutorial messages
    func startTutorial() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            if currentMessageIndex < tutorialMessages.count - 1 {
                currentMessageIndex += 1
            } else {
                isTutorialComplete = true
                timer.invalidate()
            }
        }
    }
}

struct PageView: View {
    let h: Int
    let v: Int
    @ObservedObject var regionManager = RegionManager.shared
    @Environment(\.pagerCurrentPage) var mainPage
    @State private var isCurrent = false
    @State private var percent: Double = 0
    var smallNoise: UIImage = generateNoiseImage(w: 1000, h: 1000, whiten_factor: 0.99, fine_factor: 0.001) ?? UIImage()
    var denseNoise: UIImage = generateNoiseImage(w: 500, h: 500, whiten_factor: 0.99, fine_factor: 0.0001) ?? UIImage()
    @State private var lastShakeTime: Date = Date.distantPast
    private let minimumShakeInterval: TimeInterval = 1.0 // 1秒的最小间隔
    
    var body: some View {
        VStack {
            Color.clear
                .overlay(
                    GeometryReader { geometry in
                        let gridSize = CGSize(width: 4, height: 8)
                        let blockWidth = geometry.size.width / CGFloat(gridSize.width)
                        let blockHeight = geometry.size.height / CGFloat(gridSize.height)
                        let key = CanvasViewModel.shared.getIndex(h: h, v: v)
                        
                        if let blocks = regionManager.allBlocks[key] {
                            let columns = Array(repeating: GridItem(.fixed(blockWidth), spacing: 0), count: Int(gridSize.width))
                            ZStack {
                                LazyVGrid(columns: columns, spacing: 0) {
                                    ForEach(blocks.indices, id: \.self) { index in
                                        BlockView(word: .constant(blocks[index].text ?? ""), block: blocks[index])
                                            .frame(width: blockWidth, height: blockHeight)
                                    }
                                }
                                .layoutPriority(1)
                                
                                Image(uiImage: denseNoise)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .opacity(0.1)
                                
                                Image(uiImage: smallNoise)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .opacity(0.25)
                            }
                            .background(Color.black)
                        }
                    }
                )
            // 为了 onshake 必须知道当前在哪个页面
                .onPageVisible { percent in
                    if let percent {
                        self.percent = percent
                        CanvasViewModel.shared.updateCurrentMainPage(horizontal: h, vertical: v)
                    }
                }
                .task(id: mainPage) {
                    if let mainPage, mainPage.horizontal == h, mainPage.vertical == v {
                        isCurrent = true
                    } else {
                        isCurrent = false
                    }
                }
                .onShake {
                    let now = Date()
                    guard now.timeIntervalSince(lastShakeTime) >= minimumShakeInterval else {
                        return // 如果距离上次摇晃不足1秒，则忽略这次摇晃
                    }
                    lastShakeTime = now
                    
                    regionManager.reorderCurrentPage()
                    
                    // 添加震动
                    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedbackGenerator.prepare()
                    impactFeedbackGenerator.impactOccurred()
                }
                .clipped()
        }
    }
}

// 新增的位置指示器组件
struct LocationIndicator: View {
    let currentPage: (horizontal: Int, vertical: Int)?
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3) { row in
                HStack(spacing: 2) {
                    ForEach(0..<3) { col in
                        if isCurrentPosition(row: row, col: col) {
                            // 当前位置的点
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white,
                                            Color.white.opacity(0.3)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 3
                                    )
                                )
                                .frame(width: 6, height: 6)
                                .blur(radius: 0.3)
                        } else {
                            // 其他位置的点
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.4))
                .blur(radius: 3)
        )
        .padding(.top, 15)
    }
    
    private func isCurrentPosition(row: Int, col: Int) -> Bool {
        guard let currentPage = currentPage else { return false }
        let normalizedRow = ((currentPage.vertical % 3) + 3) % 3
        let normalizedCol = ((currentPage.horizontal % 3) + 3) % 3
        return row == normalizedRow && col == normalizedCol
    }
}

// Add PressActions view modifier
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

// 添加一个自定义的三角形形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
