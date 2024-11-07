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
        
        // 为第一个屏幕随机选择一个方块作为种子
        if let firstScreenBlocks = allBlocks["0-0"] {
            let randomIndex = Int.random(in: 0..<firstScreenBlocks.count)
            let seedBlock = firstScreenBlocks[randomIndex]
            seedBlock.isFlashing = false
            seedBlock.text = WordManager.shared.getRandomSeed()
            self.initWordIndex = randomIndex  // 记录初始方块的索引
            
            // 更新 allBlocks
            allBlocks["0-0"] = firstScreenBlocks
        }
        
        // 随机选择出口方块
        if let exitBlock = allBlocksList.randomElement() {
            exitBlock.isExitButton = true
        }
    }
    
    
    // 生成初始索引
    func generateFirstBlockWord(page_index: String = "0-0", count: Int = 1) {
        if self.initWordIndex == -1 {
            // 第一页的数据随机生成一个单词
             let word = generateRandomWord()
             self.initWordIndex = Int(arc4random_uniform(UInt32(11))) + 10
             allBlocks[page_index]?[self.initWordIndex ].text = word
             allBlocks = allBlocks // 重新赋值字典
            
             // 生成额外五个
            generateBlockWordRandom()
        }
     }

    
    // 生成块
    func generateBlockWord(page_index: String = "0-0", count: Int = 5) {
        let excludedIndex: Int? = self.initWordIndex
        // 确保字典中有 "0-0" 键，并且对应的数组至少有 count 个元素
        if allBlocks[page_index]?.count ?? 0 >= count {
            // 随机生成五个不同的索引
            let allIndices = Array(0..<allBlocks.count-1)
            // 如果提供了 excludedIndex，则从所有索引中排除它
           let filteredIndices = excludedIndex.map { exclude in
               allIndices.filter { $0 != exclude }
           } ?? allIndices
            let randomIndices = filteredIndices.shuffled().prefix(count)
            for index in randomIndices {
                // 为每个索引生成一个新的单词和颜色
                let word = generateRandomWord()
                // 更新对应索引的单词和颜色
                allBlocks[page_index]![index].text = word
            }
            allBlocks = allBlocks // 重新赋值字典
        }
    }
    
    
    // 生成不包含初始位置的块
    func generateBlockWordRandom(page_index: String = "0-0", count: Int = 5) {
        let excludedIndex: Int? = self.initWordIndex
        // 确保字典中有 "0-0" 键，并且对应的数组至少有 count 个元素
        if allBlocks[page_index]?.count ?? 0 >= count {
            // 随机生成五个不同的索引
            let allIndices = Array(self.initWordIndex-10..<32-10)
            // 如果提供了 excludedIndex，则从所有索引中排除它
           let filteredIndices = excludedIndex.map { exclude in
               allIndices.filter { $0 != exclude }
           } ?? allIndices
            let randomIndices = filteredIndices.shuffled().prefix(count)
            for index in randomIndices {
                // 为每个索引生成一个新的单词和颜色
                let word = generateRandomWord()
                // 更新对应索引的单词和颜色
                allBlocks[page_index]![index].text = word
            }
            allBlocks = allBlocks // 重新赋值字典
        }
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
        if timer != nil {
            return
        }
        
        // 每 3 秒触发一次定时器
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 遍历所有页面的方块
            for (_, blocks) in self.allBlocks {
                for block in blocks {
                    if block.isFlashing {
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
        guard let mainPage = CanvasViewModel.shared.currentMainPage else {
            print("无法获取当前页面")
            return
        }
        
        let pageIndex = CanvasViewModel.shared.getIndex(h: mainPage.horizontal, v: mainPage.vertical)
        
        // Get the blocks for the current page and filter non-flashing blocks
        guard let blocks = allBlocks[pageIndex] else {
            print("未找到该页面的 blocks")
            return
        }
        
        let nonFlashingBlocks = blocks.enumerated().filter { !$0.element.isFlashing }
        var textsToReorder: [String] = []
        var blockIds: [String] = []
        var blockPositions: [(Int, Int)] = [] // Store positions here
        
        for (_, block) in nonFlashingBlocks {
            if let text = block.text {
                textsToReorder.append(text)
                blockIds.append(block.id)
                blockPositions.append(block.position) // Add each block's position
            }
        }
        
        // Call LLM API to reorder text
        if !textsToReorder.isEmpty {
            Task(priority: .userInitiated) {  // Explicitly specify Task return type as Void
                let result: [String]? = await reorderTextWithLLM(textsToReorder)  // Explicit type for result
                
                if let reorderedText = result {
                    for (index, blockId) in blockIds.enumerated() {
                        if index < reorderedText.count {
                            updateBlockText(for: pageIndex, blockID: blockId, newText: reorderedText[index])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let currentBlockPositions = blockPositions // Create a local copy
                        let currentReorderedText = reorderedText   // Create a local copy

                        if let existingIndex = self.orderedPoem.firstIndex(where: { $0.0 == pageIndex }) {
                            // Update entry if it exists
                            if !self.arePositionsEqual(self.orderedPoem[existingIndex].1, currentBlockPositions) || self.orderedPoem[existingIndex].2 != currentReorderedText {
                                self.orderedPoem[existingIndex] = (pageIndex, currentBlockPositions, currentReorderedText)
                                print("Updated orderedPoem for pageIndex \(pageIndex) with positions: \(currentBlockPositions) and reorderedText: \(currentReorderedText)")
                            } else {
                                print("No update needed. orderedPoem for pageIndex \(pageIndex) is already up-to-date.")
                            }
                        } else {
                            // Append new entry if it doesn't exist
                            self.orderedPoem.append((pageIndex, currentBlockPositions, currentReorderedText))
                            print("Added new entry to orderedPoem for pageIndex \(pageIndex) with positions: \(currentBlockPositions) and reorderedText: \(currentReorderedText)")
                        }
                        print("Current orderedPoem state: \(self.orderedPoem)")
                    }
                    
                } else {
                    print("LLM 重���序失败")
                }
            }
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
            self.allBlocks = self.allBlocks // 重新赋值字典

        }
    
        
    }
    
    // find out how many blocks have been fixed
    func occupancyRate(for pageIndex: String) -> Double {
        guard let blocks = allBlocks[pageIndex] else {
            print("No blocks found for the specified page index.")
            return 0.0
        }
        
        let nonFlashingBlocks = blocks.filter { !$0.isFlashing }
        let totalBlocks = blocks.count
        
        // Calculate the occupancy rate as a ratio of non-flashing blocks to total blocks
        return totalBlocks > 0 ? Double(nonFlashingBlocks.count) / Double(totalBlocks) : 0.0
    }
    
    
    // 使用 LLM API 重新排序文本
    func reorderTextWithLLM(_ texts: [String]) async -> [String]? {
        let prompt = "Reorder these words into a poetic line, with no new words added, return exactly the new line and nothing else: \(texts.joined(separator: " "))"
        
        // Assuming WordManager.shared.generateWordBank(from:) is an async function
//        await WordManager.shared.generateWordBank(from: prompt)
        
        // Retrieve the response from the word list
        let response: [String] = WordManager.shared.wordList
        
        // Return the response, or nil if empty
        return response.isEmpty ? nil : response
    }
    
    
}


