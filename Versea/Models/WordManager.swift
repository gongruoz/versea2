//
//  WordManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/10/25.
//
import Foundation


// WordManager 类，用于处理 LLM 的 string response 并输出一个 [String] 的词库
class WordManager {
    static let shared = WordManager()
    let theTogetherAIConnector = TogetherAIConnector()
    @Published var wordList: [String] = [] // 缓存已加载的词库

    // 异步生成并保存词库
    func generateWordBank(from prompt: String) async {
        do {
            let response = try await theTogetherAIConnector.processPrompt(prompt: prompt)
            let wordBank = processPhrase(response)
            
            // 将新生成的词追加到现有的 wordList，而不是替换
            DispatchQueue.main.async {
                self.wordList.append(contentsOf: wordBank)
                print("词库生成完成: \(self.wordList)")
            }
        } catch {
            print("生成词库失败: \(error)")
        }
    }

    // takes in a sentence, outputs an array of words
    func processPhrase(_ phrase: String) -> [String] {
        // 移除标点符号
        let punctuationCharacterSet = CharacterSet.punctuationCharacters
        let cleanedPhrase = phrase.unicodeScalars.filter { !punctuationCharacterSet.contains($0) }.map { String($0) }.joined()

        // 将句子分割成单词，并转换为大写字母
        let wordsArray = cleanedPhrase
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty } // 移除空的元素
            .map { $0.uppercased() }
        
        return wordsArray
    }
}

// get the response from Together AI

struct TogetherAIConnector {
    let togetherAIURL = URL(string: "https://api.together.xyz/v1/chat/completions")
    var togetherAIKey: String {
        return "Bearer 7cab015eb4e448b4ccfedea1291720dac1a822b3915a5ea9f5cb66fa75cdcc88"
    }

    func processPrompt(prompt: String) async throws -> String {
        var request = URLRequest(url: self.togetherAIURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.togetherAIKey, forHTTPHeaderField: "Authorization")
        
        let httpBody: [String: Any] = [
            "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        var httpBodyJson: Data
        do {
            httpBodyJson = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            throw URLError(.badURL) // 抛出一个自定义错误
        }
        request.httpBody = httpBodyJson
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonStr)")
                
                let responseHandler = TogetherAIResponseHandler()
                if let response = responseHandler.decodeJson(jsonString: jsonStr) {
                    return response.choices.first?.message.content ?? "No response"
                }
            }
        } catch {
            throw error  // 传递错误
        }
        return "" // if error
    }
}

struct TogetherAIResponseHandler {
    func decodeJson(jsonString: String) -> TogetherAIResponse? {
        let json = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(TogetherAIResponse.self, from: json)
            return response
        } catch {
            print("Error decoding Together AI response: \(error)")
        }
        return nil
    }
}

struct TogetherAIResponse: Codable {
    var choices: [Choice]
}

struct Choice: Codable {
    var message: Message
}

struct Message: Codable {
    var role: String
    var content: String
}
