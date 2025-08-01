import Foundation
import CoreLocation
import WeatherKit
import Combine
import MapKit
import SwiftUI

@MainActor
class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = WeatherManager()
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    @Published var currentWeather: Weather?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String? = nil
    @Published var lastKnownLocation: CLLocation?
    @Published var cityName: String? = nil
    var hasLoadedGreetingThisSession = false
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.locationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            } else if status == .denied || status == .restricted {
                self.locationError = "Location permission denied."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.lastKnownLocation = location
        }
        Task {
            await fetchWeather(for: location)
            await fetchCity(for: location)
        }
    }
    
    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            await MainActor.run {
                self.currentWeather = weather
            }
        } catch {
            await MainActor.run {
                self.locationError = "Failed to fetch weather: \(error.localizedDescription)"
            }
        }
    }

    func fetchCity(for location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let city = placemarks.first?.locality {
                await MainActor.run { self.cityName = city }
            } else if let area = placemarks.first?.subAdministrativeArea {
                await MainActor.run { self.cityName = area }
            } else {
                await MainActor.run { self.cityName = nil }
            }
        } catch {
            await MainActor.run { self.cityName = nil }
        }
    }
    
    // MARK: - Greeting Logic
    func weatherSummary() -> String {
        guard let weather = currentWeather else { return "nice" }
        switch weather.currentWeather.condition {
        case .clear: return "sunny"
        case .cloudy, .mostlyCloudy, .partlyCloudy: return "cloudy"
        case .rain, .drizzle: return "rainy"
        case .thunderstorms: return "stormy"
        case .snow, .flurries, .blizzard: return "cold and snowy"
        case .haze: return "foggy"
        default:
            let temp = weather.currentWeather.temperature.value
            if temp >= 28 { return "hot" }
            if temp <= 12 { return "chilly" }
            return "nice"
        }
    }
    
    func generateGreeting(userName: String) -> String {
        let now = Date()
        let city = cityName ?? "your area"
        let hour = Calendar.current.component(.hour, from: now)
        let isHot = currentWeather?.currentWeather.temperature.value ?? 0 >= 28
        let isCold = currentWeather?.currentWeather.temperature.value ?? 0 <= 12
        // Special weather+time-based morning greeting
        if hour >= 6 && hour < 11, currentWeather != nil {
            let weatherWord = weatherSummary()
            let message = "Good morning, it's going to be \(weatherWord) today in \(city)! Start your day right, what’s for breakfast? ☀️"
            let greetings = ["Hi", "Hey", "Hello", "Hi there", "Hey there"]
            let greeting = greetings.randomElement() ?? "Hi"
            return "\(greeting) \(userName), \(message)"
        }
        // Templates
        let weatherTemplates = [
            "It's a hot one in (location) today! 🥤 What cool and refreshing meal did you have to beat the heat?",
            "Chilly weather in (location) calls for a cosy meal 🍲 What warming dish kept you snug tonight?"
        ]
        let timeTemplates = [
            "Good morning! ☀️ What did you have for breakfast today? 🍳",
            "Lunch time already! 🥪 What did you eat for lunch?",
            "Dinner’s just finished!, what delicious dish did you make tonight? 🍽️"
        ]
        let friendlyTemplates = [
            "Welcome back! Every meal you track is a win 🏆 what did you just eat?",
            "Ready to take another step toward your health goals? 💪 What was your last meal?",
            "Glad to see you again! 🌱 What mindful choice did you make for your last meal?"
        ]
        var candidates: [String] = []
        // Weather context
        if isHot {
            candidates.append(weatherTemplates[0])
        } else if isCold {
            candidates.append(weatherTemplates[1])
        }
        // Time context
        if hour >= 6 && hour < 11 {
            candidates.append(timeTemplates[0])
        } else if hour >= 11 && hour < 15 {
            candidates.append(timeTemplates[1])
        } else if hour >= 17 && hour < 22 {
            candidates.append(timeTemplates[2])
        }
        // Always add friendly
        candidates.append(contentsOf: friendlyTemplates)
        // Pick one at random
        let template = candidates.randomElement() ?? friendlyTemplates[0]
        let message = template.replacingOccurrences(of: "(location)", with: city)
        let greetings = ["Hi", "Hey", "Hello", "Hi there", "Hey there"]
        let greeting = greetings.randomElement() ?? "Hi"
        return "\(greeting) \(userName), \(message)"
    }
    
    static func mealTimeString(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<11:
            return "breakfast time"
        case 11..<15:
            return "lunch time"
        case 15..<17:
            return "afternoon tea time"
        case 17..<22:
            return "dinner time"
        default:
            return "snack time"
        }
    }
    
    func weatherBasedRemark() -> String {
        guard let weather = currentWeather else {
            return "Hope you're having a great day!"
        }
        let temp = weather.currentWeather.temperature.value
        let condition = weather.currentWeather.condition
        if temp >= 28 {
            return "It's hot out, maybe something fresh and cold?"
        } else if temp <= 12 {
            return "Chilly day, how about something comforting and warm?"
        } else if condition == .rain || condition == .thunderstorms {
            return "Rainy day, maybe a cosy meal?"
        } else if condition == .clear {
            return "Beautiful weather, maybe something light and energising?"
        } else {
            return "Enjoy your meal!"
        }
    }
} 
