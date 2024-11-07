import Foundation

class TogetherAIService {
    private let togetherAIURL = URL(string: "https://api.together.xyz/v1/chat/completions")
    private var togetherAIKey: String {
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
        
        request.httpBody = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let jsonStr = String(data: data, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        let responseHandler = TogetherAIResponseHandler()
        guard let response = responseHandler.decodeJson(jsonString: jsonStr) else {
            throw URLError(.cannotParseResponse)
        }
        
        return response.choices.first?.message.content ?? "No response"
    }
} 
