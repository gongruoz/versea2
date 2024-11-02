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
    var initWordIdex: Int = -1  // 第一个单词的索引
    var timer: Timer? // 跟踪定时器的引用
    
    // 用于存储每个页面的诗句
    @Published var orderedPoem: [(String, [String])] = []

    
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
                            allBlocksList.append(newBlock) // Add block to global list for selecting exit
                        }
                    }
                    
                    allBlocks["\(x)-\(y)"] = blocks
                }
            }
            
            // Randomly select a single exit block from all blocks
            if let exitBlock = allBlocksList.randomElement() {
                exitBlock.isExitButton = true
            }
        }
    
    
    // 生成初始索引
    func generateFirstBlockWord(page_index: String = "0-0", count: Int = 1) {
        if self.initWordIdex == -1 {
            // 第一页的数据随机生成一个单词
             let word = generateRandomWord()
             self.initWordIdex = Int(arc4random_uniform(UInt32(11))) + 10
             allBlocks[page_index]?[self.initWordIdex ].text = word
             allBlocks = allBlocks // 重新赋值字典
            
             // 生成额外五个
            generateBlockWordRandom()
        }
     }

    
    // 生成块
    func generateBlockWord(page_index: String = "0-0", count: Int = 5) {
        let excludedIndex: Int? = self.initWordIdex
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
        let excludedIndex: Int? = self.initWordIdex
        // 确保字典中有 "0-0" 键，并且对应的数组至少有 count 个元素
        if allBlocks[page_index]?.count ?? 0 >= count {
            // 随机生成五个不同的索引
            let allIndices = Array(self.initWordIdex-10..<32-10)
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
        if let blockArray = allBlocks[page_index] {
            for blockObject in blockArray {
                if blockObject.id == blockID {
                    blockObject.text = newWord
                    break
                }
            }
            allBlocks[page_index] = blockArray // 更新数组
        }
        allBlocks = allBlocks // 重新赋值字典
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
                    if block.isFlashing == true {
                        // 随机生成新的文字和颜色
                        let randomWord: String
                        if arc4random_uniform(3) == 1 {
                            randomWord = self.generateRandomWord()
                        } else {
                            randomWord = ""
                        }
                        

                        // 更新方块的文字和背景颜色
                        self.update(for: block.page_index, blockID: block.id, newWord: randomWord)
                    }
                }
            }
        }
    }
    
    
    // 非异步版本，直接从缓存中获取一个随机单词
    func generateRandomWord() -> String {
        // 从已缓存的词库中选取一个随机单词
        let randomWord = WordManager.shared.wordList.randomElement() ?? ""
        return randomWord
    }
    
        
    
    func reorderCurrentPage() {
        // 获取当前页面的 `page_index`
        guard let mainPage = CanvasViewModel.shared.currentMainPage else {
            print("无法获取当前页面")
            return
        }
        
        let pageIndex = CanvasViewModel.shared.getIndex(h: mainPage.horizontal, v: mainPage.vertical)
        
        // 获取当前页面的 `blocks`，并筛选出 `isFlashing = false` 的 `blocks`
        guard let blocks = allBlocks[pageIndex] else {
            print("未找到该页面的 blocks")
            return
        }
        
        // 找到 `isFlashing = false` 的 blocks
        let nonFlashingBlocks = blocks.filter { !$0.isFlashing }
        
        // 收集这些 blocks 的文本内容和 ID
        var textsToReorder = [String]()
        var blockIds = [String]()
        
        for block in nonFlashingBlocks {
            if let text = block.text {
                textsToReorder.append(text)
                blockIds.append(block.id)
            }
        }
        
        // 调用 LLM API 重新排序文本
        if textsToReorder != [] {
            Task {
                if let reorderedText = await reorderTextWithLLM(textsToReorder) {
                    // 将新排序后的文本写回到相应的 blocks
                    for (index, blockId) in blockIds.enumerated() {
                        if index < reorderedText.count {
                            updateBlockText(for: pageIndex, blockID: blockId, newText: reorderedText[index])
                        }
                    }
                    
                    // 更新 orderedPoem 数组，使其与 reorderTextWithLLM 返回的顺序一致
                    DispatchQueue.main.async {
                        // Check if orderedPoem already contains an entry for pageIndex
                        if let index = self.orderedPoem.firstIndex(where: { $0.0 == pageIndex }) {
                            // If reorderedText is different from the existing entry, update it
                            if self.orderedPoem[index].1 != reorderedText {
                                self.orderedPoem[index].1 = reorderedText
                                print("Updated orderedPoem for pageIndex \(pageIndex) with new reorderedText: \(reorderedText)")
                            } else {
                                print("No update needed. reorderedText for pageIndex \(pageIndex) is already up-to-date.")
                            }
                        } else {
                            // Append a new entry if pageIndex does not exist in orderedPoem
                            self.orderedPoem.append((pageIndex, reorderedText))
                            print("Added new entry to orderedPoem for pageIndex \(pageIndex) with reorderedText: \(reorderedText)")
                        }
                        print("Current orderedPoem state: \(self.orderedPoem)")
                    }
                    
                } else {
                    print("LLM 重排序失败")
                }
            }
        }
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
        
        // 异步调用生成词库，等待其完成
        await WordManager.shared.generateWordBank(from: prompt)
        
        // 从生成的词库中获取内容
        let response = WordManager.shared.wordList
        
        
        // 返回内容，或者返回 nil 表示失败
        return response.isEmpty ? nil : response
    }
    
    
}


