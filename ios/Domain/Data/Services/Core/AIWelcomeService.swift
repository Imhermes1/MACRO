import Foundation

/// AI-powered welcome message service using GPT-4.1-mini-2025-04-14
/// Generates personalized greetings using weather, time, and user context
class AIWelcomeService: ObservableObject {
    static let shared = AIWelcomeService()
    
    private let weatherManager = WeatherManager.shared
    private let mainAIService = MainAIService.shared
    
    private init() {}
    
    /// Generate a smart, contextual welcome message using GPT-4.1-mini
    func generateWelcomeMessage(for userName: String) async -> String {
        let context = buildUserContext(userName: userName)
        let prompt = buildPrompt(context: context)
        
        do {
            let aiResponse = try await mainAIService.generateResponse(prompt: prompt)
            return aiResponse
        } catch {
            print("AI Welcome Error: \(error)")
            // Fallback to smart templates
            return generateSmartGreeting(context: context)
        }
    }
    
    /// Build user context from available data sources
    private func buildUserContext(userName: String) -> UserContext {
        let weatherSummary = weatherManager.weatherSummary()
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay = getTimeOfDay(hour: hour)
        
        return UserContext(
            userName: userName,
            weather: weatherSummary,
            timeOfDay: timeOfDay,
            hour: hour
        )
    }
    
    /// Build prompt for GPT-4.1-mini
    private func buildPrompt(context: UserContext) -> String {
        return """
        Generate a friendly, personalized welcome message for a nutrition tracking app user.
        
        User: \(context.userName)
        Weather: \(context.weather)
        Time: \(context.timeOfDay) (\(context.hour):00)
        
        Requirements:
        - Keep it conversational and encouraging
        - 1-2 sentences max
        - Mention food/nutrition naturally
        - Use Australian English
        - Be specific to the time and weather context
        - Sound like a supportive mate, not robotic
        """
    }
    
    /// Fallback smart greeting using templates
    private func generateSmartGreeting(context: UserContext) -> String {
        let greetings = ["Hi", "Hey", "Hello", "Good to see you", "Welcome back"]
        let greeting = greetings.randomElement() ?? "Hi"
        
        var message = "\(greeting) \(context.userName)!"
        
        // Weather + time combinations
        if context.weather == "hot" && context.timeOfDay == "morning" {
            message += " It's already getting warm this morning. How about something light and refreshing to start your day?"
        } else if context.weather == "hot" && context.timeOfDay == "afternoon" {
            message += " This heat is intense! What cooling foods have you been enjoying?"
        } else if context.weather == "cold" && context.timeOfDay == "evening" {
            message += " Perfect weather for something warm and cozy. What's on the menu tonight?"
        } else if context.weather == "cold" && context.timeOfDay == "morning" {
            message += " Bundle up! What warming breakfast will fuel your chilly day?"
        } else if context.timeOfDay == "morning" {
            message += " Ready to fuel up for the day? What's your breakfast plan?"
        } else if context.timeOfDay == "afternoon" {
            message += " How's your day going? What have you been munching on?"
        } else if context.timeOfDay == "evening" {
            message += " Winding down for the evening. What delicious dinner are you planning?"
        } else {
            message += " What tasty food adventure are we tracking today?"
        }
        
        return message
    }
    
    /// Determine time of day from hour
    private func getTimeOfDay(hour: Int) -> String {
        switch hour {
        case 5..<12:
            return "morning"
        case 12..<17:
            return "afternoon"
        case 17..<22:
            return "evening"
        default:
            return "night"
        }
    }
}

/// User context for generating personalized messages
struct UserContext {
    let userName: String
    let weather: String
    let timeOfDay: String
    let hour: Int
}
