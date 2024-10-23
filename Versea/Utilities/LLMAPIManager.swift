// LLMAPIManager.swift
// Versea
// Created by Hazel Gong on 2024/9/15.

import Foundation

class LLMAPIManager {
    static let shared = LLMAPIManager()
    private let apiKey = "Bearer 7cab015eb4e448b4ccfedea1291720dac1a822b3915a5ea9f5cb66fa75cdcc88" // Replace with your actual API key
    private init() {}

    // Function to fetch a generated phrase from Together AI API
    func fetchPhrase(from prompt: String, completion: @escaping (String) -> Void) {
        // Prepare the API URL
        let url = URL(string: "https://api.together.xyz/v1/chat/completions")!

        // Create a URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        // Prepare the request body (parameters)
        let parameters: [String: Any] = [
            "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo", // The Together AI model
            "messages": [
                ["role": "user", "content": prompt] // Your input prompt
            ]
        ]

        // Convert parameters to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        // Create a URLSession task to fetch the response
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching Together AI response: \(error.localizedDescription)")
                return
            }

            // Print the HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received from Together AI API")
                return
            }

            // Print the raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }

            // Parse the response
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let generatedText = choices.first?["content"] as? String {
                    let trimmedText = generatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Print the generated text for debugging
                    print("Generated Response: \(trimmedText)") // Debug output
                    
                    // Call the completion handler with the generated text
                    DispatchQueue.main.async {
                        completion(trimmedText) // Return the generated text
                    }
                } else {
                    print("Unexpected JSON structure: \(String(describing: json))")
                }
            } catch {
                print("Failed to parse Together AI response: \(error.localizedDescription)")
            }
        }

        // Start the task
        task.resume()
    }
}
