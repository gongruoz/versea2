//
//  WordManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/10/25.
//
import Foundation

class WordManager {
    static let shared = WordManager()
    private let aiService = TogetherAIService()
    @Published var wordList: [String] = []
    @Published var seedWords: [String] = []

    init() {
        // 加载主词库
        if let poems = loadMarkdownContent(from: "poems") {
            wordList = processPhrase(poems)
            print("主词库加载完成: \(wordList)")
        }
        
        // 加载种子词库
        if let seeds = loadMarkdownContent(from: "seeds") {
            seedWords = processPhrase(seeds)
            print("种子词库加载完成: \(seedWords)")
        }
    }
    
    // 获取随机种子词
    func getRandomSeed() -> String {
        return seedWords.randomElement() ?? ""
    }
    
    // 处理文本，分割成单词
    func processPhrase(_ phrase: String) -> [String] {
        let punctuationCharacterSet = CharacterSet.punctuationCharacters
        let cleanedPhrase = phrase.unicodeScalars.filter { !punctuationCharacterSet.contains($0) }.map { String($0) }.joined()

        return cleanedPhrase
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
    }
    
    // 仅保留重排序功能
    func reorderWords(_ texts: [String], retryCount: Int = 0) async -> [String]? {
        let prompt = "Reorder these words into a poetic line, with no new words added, return exactly the new line and nothing else: \(texts.joined(separator: " "))"
        do {
            let response = try await aiService.processPrompt(prompt: prompt)
            return processPhrase(response)
        } catch {
            if retryCount < maxRetryCount {
                print("网络错误，重试第 \(retryCount + 1) 次")
                return await reorderWords(texts, retryCount: retryCount + 1)
            } else {
                print("达到最大重试次数，无法重排序")
                return nil
            }
        }
    }
    
    private let maxRetryCount = 100
}
