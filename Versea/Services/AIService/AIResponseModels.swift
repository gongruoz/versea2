import Foundation

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

struct TogetherAIResponseHandler {
    func decodeJson(jsonString: String) -> TogetherAIResponse? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(TogetherAIResponse.self, from: jsonData)
        } catch {
            print("Error decoding Together AI response: \(error)")
            return nil
        }
    }
} 