//
//  RegionManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/10/10.
//

import Foundation
import SwiftUI

class RegionManager: ObservableObject {
    static let shared = RegionManager()
    @Published var allBlocks: [String: [Block]] = [:]
    var initWordIndex: Int = -1  // 第一个单词的索引
    var timer: Timer? // 跟踪定时器的引用
    
    // 用于存储每个页面的诗句
    @Published var orderedPoem: [(String, [(Int, Int)], [String])] = []
    
    private var isReordering = false  // 添加一个标志来追踪是否正在重排序
    
    init() {
        var allBlocksList: [Block] = []
        
        for x in 0..<3 {
            for y in 0..<3 {
                var blocks: [Block] = []
                for j in 0..<8 {
                    for k in 0..<4 {
                        let position = (x: j, y: k)
                        let id = "\(x)\(y)-\(j)\(k)"
                        let page_index = "\(x)-\(y)"
                        
                        let newBlock = Block(id: id, page_index: page_index, position: position)
                        blocks.append(newBlock)
                        allBlocksList.append(newBlock)
                    }
                }
                
                allBlocks["\(x)-\(y)"] = blocks
            }
        }
        
        // 固定在第三行第二列的位置 (2, 1)
        if let firstScreenBlocks = allBlocks["0-0"] {
            if let seedBlock = firstScreenBlocks.first(where: { block in
                block.position == (x: 1, y: 0)
            }) {
                seedBlock.isFlashing = false
                seedBlock.isSeedPhrase = true  // 标记为种子词
                seedBlock.text = WordManager.shared.getRandomSeed()
                seedBlock.coordinateText = "(0, 0)"  // 添加坐标文本
                self.initWordIndex = firstScreenBlocks.firstIndex(where: { $0.id == seedBlock.id }) ?? -1
                
                // 更新 allBlocks
                allBlocks["0-0"] = firstScreenBlocks
            }
        }
        
        // 设置出口（INFINITY 按钮）
        let forbiddenPages = ["0-0", "0-1", "0-2", "1-0", "2-0"]
        let validPages = allBlocks.keys.filter { !forbiddenPages.contains($0) }

        if let randomPage = validPages.randomElement(),
           let pageBlocks = allBlocks[randomPage] {
            // 找到右下角的方块 (7, 3)
            if let exitBlock = pageBlocks.first(where: { block in
                block.position == (x: 7, y: 3)  // 最右下角的位置
            }) {
                exitBlock.isExitButton = true
            }
        }
        
        // 在初始化时就开始闪烁
        startAutoFlashing()
    }
    

    func update(for page_index: String, blockID: String, newWord: String) {
        if let index = allBlocks[page_index]?.firstIndex(where: { $0.id == blockID }) {
            DispatchQueue.main.async {
                self.allBlocks[page_index]?[index].text = newWord
                self.objectWillChange.send()
            }
        }
    }
    
    
    func startAutoFlashing() {
        // 如果定时器已经存在，不再创建新的定时器
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: true) { [weak self] _ in
            self?.updateRandomWords()
        }
    }
    
    // 清理定时器
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    
    // 非异步版本，直接从缓存中获取一个随机单词
    func generateRandomWord() -> String {
        // 从已缓存的词库中选取一个随机单词
        let randomWord = WordManager.shared.wordList.randomElement() ?? ""
        return randomWord
    }
    
        
    
    func reorderCurrentPage() {
        // 如果正在重排序，直接返回
        guard !isReordering else { return }
        
        // 设置标志
        isReordering = true
        
        // 1. 获取当前页面信息
        guard let mainPage = CanvasViewModel.shared.currentMainPage else {
            isReordering = false
            return
        }
        let pageIndex = CanvasViewModel.shared.getIndex(h: mainPage.horizontal, v: mainPage.vertical)
        
        // 2. 获取当前页面的所有非闪烁方块
        guard let blocks = allBlocks[pageIndex] else { return }
        let nonFlashingBlocks = blocks.enumerated().filter {
            !$0.element.isFlashing &&
            !$0.element.isSeedPhrase  // 排除种子词
        }
        
        // 3. 收集需要重排序的信息
        var textsToReorder: [String] = []
        var blockIds: [String] = []
        var blockPositions: [(Int, Int)] = []
        
        for (_, block) in nonFlashingBlocks {
            if let text = block.text {
                textsToReorder.append(text)
                blockIds.append(block.id)
                blockPositions.append(block.position)
            }
        }
        
        // Capture all values needed before async block
        let capturedPageIndex = pageIndex
        let capturedBlockIds = blockIds
        let capturedBlockPositions = blockPositions
        
        if !textsToReorder.isEmpty {
            Task {
                if let reorderedText = await reorderTextWithLLM(textsToReorder) {
                    // Use captured values
                    for (index, blockId) in capturedBlockIds.enumerated() {
                        if index < reorderedText.count {
                            updateBlockText(for: capturedPageIndex, blockID: blockId, newText: reorderedText[index])
                        }
                    }
                    
                    // Update orderedPoem using captured values
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        if let existingIndex = self.orderedPoem.firstIndex(where: { $0.0 == capturedPageIndex }) {
                            if !self.arePositionsEqual(self.orderedPoem[existingIndex].1, capturedBlockPositions) ||
                               self.orderedPoem[existingIndex].2 != reorderedText {
                                self.orderedPoem[existingIndex] = (capturedPageIndex,
                                                                 capturedBlockPositions,
                                                                 reorderedText)
                            }
                        } else {
                            self.orderedPoem.append((capturedPageIndex,
                                                   capturedBlockPositions,
                                                   reorderedText))
                        }
                    }
                }
                // 重置标志
                DispatchQueue.main.async {
                    self.isReordering = false
                }
            }
        } else {
            // 如果没有文本需要重排序，也要重置标志
            isReordering = false
        }
    }
    
    
    // helper
    func arePositionsEqual(_ lhs: [(Int, Int)], _ rhs: [(Int, Int)]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (index, element) in lhs.enumerated() {
            if element != rhs[index] {
                return false
            }
        }
        return true
    }
    
    
    // 更新指定 block 的文本
    func updateBlockText(for pageIndex: String, blockID: String, newText: String) {
        guard let blocks = allBlocks[pageIndex] else { return }

        // 更新 block 的文本内容
        for block in blocks {
            if block.id == blockID {
                DispatchQueue.main.async {
                    block.text = newText
                }
                break
            }
        }

        // 更新 allBlocks
        DispatchQueue.main.async {
            self.allBlocks[pageIndex] = blocks
            self.allBlocks = self.allBlocks // 新赋值字典

        }
    
        
    }
    

    
    
    // 使用 LLM API 重新排序文本
    func reorderTextWithLLM(_ texts: [String]) async -> [String]? {
        // 直接使用 WordManager 的 reorderWords 方法
        if let reorderedWords = await WordManager.shared.reorderWords(texts) {
            return reorderedWords
        } else {
            // 如果 API 调用失败，使用随机打乱作为后备方案
            return texts.shuffled()
        }
    }
    
    
    func resetAll() {
        // 重置所有状态
        allBlocks = [:]  // 清空所有方块
        orderedPoem = [] // 清空诗句
        initWordIndex = -1
        timer?.invalidate()
        timer = nil
        
        // 重新初始化所有方块
        var allBlocksList: [Block] = []
        
        for x in 0..<3 {
            for y in 0..<3 {
                var blocks: [Block] = []
                for j in 0..<8 {
                    for k in 0..<4 {
                        let position = (x: j, y: k)
                        let id = "\(x)\(y)-\(j)\(k)"
                        let page_index = "\(x)-\(y)"
                        
                        let newBlock = Block(id: id, page_index: page_index, position: position)
                        blocks.append(newBlock)
                        allBlocksList.append(newBlock)
                    }
                }
                
                allBlocks["\(x)-\(y)"] = blocks
            }
            
        }
        
        // 固定在第三行第二列的位置 (2, 1)
        if let firstScreenBlocks = allBlocks["0-0"] {
            if let seedBlock = firstScreenBlocks.first(where: { block in
                block.position == (x: 2, y: 1)
            }) {
                seedBlock.isFlashing = false
                seedBlock.isSeedPhrase = true  // 标记为种子词
                seedBlock.text = WordManager.shared.getRandomSeed()
                seedBlock.coordinateText = "(0, 0)"  // 添加坐标文本
                self.initWordIndex = firstScreenBlocks.firstIndex(where: { $0.id == seedBlock.id }) ?? -1
                
                // 更新 allBlocks
                allBlocks["0-0"] = firstScreenBlocks
            }
        }
        
        // 重新设置出口（INFINITY 按钮）
        let forbiddenPages = ["0-0", "0-1", "0-2", "1-0", "2-0"]
        let validPages = allBlocks.keys.filter { !forbiddenPages.contains($0) }

        if let randomPage = validPages.randomElement(),
           let pageBlocks = allBlocks[randomPage] {
            // 找到右下角的方块 (7, 3)
            if let exitBlock = pageBlocks.first(where: { block in
                block.position == (x: 7, y: 3)  // 最右下角的位置
            }) {
                exitBlock.isExitButton = true
            }
        }
        startAutoFlashing()
        objectWillChange.send()
    }
    
    
    
    // 添加新方法
    func updateRandomWords() {
        // 遍历所有页面
        for (_, blocks) in self.allBlocks {
            // 获取可以闪烁的方块（isFlashing 为 true）
            let flashingBlocks = blocks.filter { $0.isFlashing }
            
            // 计算要更新的方块数量（1/2）
            let updateCount = max(1, flashingBlocks.count / 2)
            
            // 随机选择这些方块
            let selectedBlocks = flashingBlocks.shuffled().prefix(updateCount)
            
            // 更新选中的方块
            for block in selectedBlocks {
                // 随机生成新的文字
                let randomWord: String
                if arc4random_uniform(3) == 1 {
                    randomWord = self.generateRandomWord()
                } else {
                    randomWord = ""
                }
                
                // 更新方块的文字
                self.update(for: block.page_index, blockID: block.id, newWord: randomWord)
            }
        }
    }
}
