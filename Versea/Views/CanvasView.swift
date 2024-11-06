import SwiftUI

struct CanvasView: View {
    // Tutorial messages
    let tutorialMessages = [
        "",
        """
        keep scrolling in any direction
        to go back to the start
        """,
        "",
        """
        tap to select words
        shake to reorder them
        """,
        "",
        """
        words reveal the path
        towards the exit
        """
    ]
    
    @State private var currentMessageIndex = 0
    @State private var isTutorialComplete = false
    
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
            
            // Tutorial Overlay
            if !isTutorialComplete {
                Text(tutorialMessages[currentMessageIndex])
                    .font(.custom("IM FELL DW Pica", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .onAppear {
                        startTutorial()
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
                .onPageVisible { percent in
                    if let percent {
                        self.percent = percent
                        CanvasViewModel.shared.updateCurrentMainPage(horizontal: h, vertical: v)
                    }
                }
                .onAppear {
                    RegionManager.shared.startAutoFlashing()
                }
                .onShake {
                    RegionManager.shared.reorderCurrentPage()
                }
                .task(id: mainPage) {
                    if let mainPage, mainPage.horizontal == h, mainPage.vertical == v {
                        isCurrent = true
                        if mainPage.horizontal % 3 == 0 && mainPage.vertical % 3 == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                regionManager.generateFirstBlockWord()
                            }
                        }
                    }
                }
                .clipped()
        }
    }
}
