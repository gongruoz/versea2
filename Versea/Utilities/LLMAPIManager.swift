// LLMAPIManager.swift
// Versea
// Created by Hazel Gong on 2024/9/15.


import Foundation

class LLMAPIManager {
    static let shared = LLMAPIManager()
    private let apiKey = "Bearer 7cab015eb4e448b4ccfedea1291720dac1a822b3915a5ea9f5cb66fa75cdcc88"
    private init() {}

    // Function to fetch a generated phrase from Together AI API
    func fetchPhrase(from prompt: String, completion: @escaping (String) -> Void) {
        // 准备 API URL
        let url = URL(string: "https://api.together.xyz/v1/chat/completions")!

        // 创建 URL 请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // 确保内容类型为 JSON
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        // 请求体（参数）
        let parameters: [String: Any] = [
            "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo", // Together AI 模型
            "messages": [
                ["role": "user", "content": prompt] // 输入 prompt
            ]
        ]

        // 将请求体转为 JSON 数据
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        // 创建 URLSession 任务以获取响应
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching Together AI response: \(error.localizedDescription)")
                return
            }

            // 打印 HTTP 响应状态码
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received from Together AI API")
                return
            }

            // 打印服务器返回的原始响应数据（无论成功与否）
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(responseString)") // 调试用，打印服务器返回的原始数据
            }

            // 尝试解析 JSON 响应
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let generatedText = choices.first?["content"] as? String {
                    let trimmedText = generatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 返回生成的文本
                    DispatchQueue.main.async {
                        completion(trimmedText) // 通过回调返回生成的文本
                    }
                } else {
                    print("Unexpected JSON structure: \(String(describing: json))")
                }
            } catch {
                print("Failed to parse Together AI response: \(error.localizedDescription)")
            }
        }

        // 启动任务
        task.resume()
    }
    
    
}
