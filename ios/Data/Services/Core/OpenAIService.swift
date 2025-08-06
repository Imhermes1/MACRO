import Foundation

/// Main AI service for GPT-4.1-mini integration
/// Can be swapped to other AI providers (Claude, Gemini, etc.) without changing dependent code
class MainAIService {
    static let shared = MainAIService()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4.1-mini-2025-04-14"
    
    private init() {
        // TODO: Store API key securely in keychain or environment
        self.apiKey = "YOUR_OPENAI_API_KEY" // Replace with actual key
    }
    
    /// Generate AI response using current AI provider (GPT-4.1-mini)
    func generateResponse(prompt: String) async throws -> String {
        guard !apiKey.isEmpty && apiKey != "YOUR_OPENAI_API_KEY" else {
            // Fallback to smart templates when no API key
            return "Smart response placeholder - API key needed for AI"
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a friendly, encouraging nutrition coach for a health tracking app. Keep responses conversational, brief (1-2 sentences), and supportive. Use Australian English."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.8
        ]
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIServiceError.encodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw AIServiceError.requestFailed
            }
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let choices = jsonResponse?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw AIServiceError.invalidResponse
            }
            
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
}

/// AI service errors (provider-agnostic)
enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case requestFailed
    case invalidResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid AI API URL"
        case .encodingError:
            return "Failed to encode request"
        case .requestFailed:
            return "AI API request failed"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
