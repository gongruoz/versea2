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
        // 使用 WordLibrary 中的常量
        wordList = processPhrase(WordLibrary.poems)
        seedWords = WordLibrary.seeds
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespaces) }
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
        let prompt = """
        Let's play a poetry game. Write a line of poem of exactly \(texts.count) words. 
        The poem is inspired by the words inside []:
        [\(texts.joined(separator: " "))] 
        DO NOT include explanatory text.
        Directly return the line of poem. 
        Game starts now. 
        """
        
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
