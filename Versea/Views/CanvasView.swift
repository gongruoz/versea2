import SwiftUI

struct CanvasView: View {
    
  var body: some View {
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
  }
}

struct PageView: View {
    
    let h: Int
    let v: Int
    @ObservedObject var regionManager = RegionManager.shared
    @Environment(\.pagerCurrentPage) var mainPage
    @State var isCurrent = false
    @State var percent: Double = 0
//    var bigNoise: UIImage = generateNoiseImage(w: 50, h: 60, whiten_factor: 0.99, fine_factor: 0.001) ?? UIImage() // fixed
    var smallNoise: UIImage = generateNoiseImage(w: 1000, h: 1000, whiten_factor: 0.99, fine_factor: 0.001) ?? UIImage() // fixed
    var denseNoise: UIImage = generateNoiseImage(w: 500, h: 500, whiten_factor: 0.99, fine_factor: 0.0001) ?? UIImage() // fixed


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
                                    ForEach(blocks, id: \.id) { block in
                                        BlockView(word: .constant(block.text ?? ""), block: block)
                                            .frame(width: blockWidth, height: blockHeight)
                                    }
                                }
                                .layoutPriority(1)
                                
                                Image(uiImage: denseNoise)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .opacity(0.1) // fixed
                                
                                Image(uiImage: smallNoise)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .opacity(0.25) // fixed
                                
                            }
                            
                            .background(Color.black)
                        }
                    }
                )
                .onPageVisible { percent in
                    if let percent { // 加载百分比
                        // 页面出现的时候，需要做数据处理操作
                        self.percent = percent
                        // 更新当前页面索引
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
                    if let mainPage {
                        if mainPage.horizontal == h, mainPage.vertical == v {
                            isCurrent = true
                            if mainPage.horizontal % 3 == 0 && mainPage.vertical % 3 == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    regionManager.generateFirstBlockWord()
                                }
                            }
                        }
                    }
                }
                .clipped()
                
                
            
        }
    }
    
    
}



