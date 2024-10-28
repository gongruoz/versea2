//
//  CanvasViewModel.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/29.
//

import Foundation

class CanvasViewModel: ObservableObject {
    static let shared = CanvasViewModel()
    @Published private var regionManager: RegionManager
    // 当前页面生成情况
    @Published var currentPageGenStatus: [String: Bool] = [:]
    // current page index
    @Published var currentMainPage: (horizontal: Int, vertical: Int)?

    
    init() {
        self.regionManager = RegionManager()
    }
    
    
    // 获取下标
    func getIndex(h: Int, v: Int) -> String {
        return "\(abs(h % 3))-\(abs(v % 3))"
    }
    
    // 更新当前页面索引
    func updateCurrentMainPage(horizontal: Int, vertical: Int) {
        self.currentMainPage = (horizontal, vertical)
    }

}
