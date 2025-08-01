//
//  SpeechManager.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import Speech
import AVFoundation
import UIKit
import SwiftUI
import Combine

@MainActor
class SpeechManager: NSObject, ObservableObject {
    // Simple shared instance - no lazy closure to avoid recursion
    static let shared = SpeechManager()
    
    @Published var isRecording = false
    @Published var speechText = ""
    @Published var lastFinalSpeech: String = ""
    @Published var error: String? = nil
    @Published var permissionStatus: PermissionStatus = .notRequested
    @Published var audioLevel: Float = 0.0 // Real-time audio level for visual feedback
    
    // Lazy-loaded components to reduce memory footprint until actually needed
    private lazy var speechRecognizer: SFSpeechRecognizer? = {
        print("📱 SpeechManager: Initializing speech recognizer")
        
        // iOS 26 compatibility improvements
        if #available(iOS 26.0, *) {
            print("📱 iOS 26 detected - using enhanced speech recognition with safety checks")
            
            // Ensure main thread for iOS 26
            if !Thread.isMainThread {
                print("⚠️ Warning: Speech recognizer must be initialized on main thread")
                // Create recognizer directly - SFSpeechRecognizer is thread-safe for initialization
                return SFSpeechRecognizer(locale: Locale(identifier: "en-AU"))
            }
        }
        
        return SFSpeechRecognizer(locale: Locale(identifier: "en-AU"))
    }()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private lazy var audioEngine: AVAudioEngine = {
        print("📱 SpeechManager: Initializing audio engine")
        
        // iOS 26 specific initialization safety
        if #available(iOS 26.0, *) {
            print("📱 iOS 26 detected - using safe audio engine initialization")
            // Ensure audio engine is created on main thread for iOS 26
            if !Thread.isMainThread {
                print("⚠️ Warning: Audio engine must be initialized on main thread")
                // AVAudioEngine must be created on main thread, but we can't use sync
                // This will be handled by ensuring SpeechManager is only accessed from main thread
                fatalError("SpeechManager must be accessed from main thread")
            }
        }
        
        return AVAudioEngine()
    }()
    private var restartCount = 0
    private let maxRestarts = 2
    private var userStopped = false
    
    // List of common food terms for contextual hints
    private let foodContextualHints: [String] = [
        "eye fillet", "scotch fillet", "steak", "chicken", "beef", "lamb", "pork", "fish", "salmon", "tuna", "potato", "mashed potato", "rice", "pasta", "burger", "fries", "egg", "toast", "avocado", "salad", "milk", "butter", "cheese", "coles", "woolworths", "aldi", "hungry jacks", "kfc", "mcdonalds", "grilld", "nandos", "subway", "dominos", "coke", "soda", "juice", "water", "spinach", "broccoli", "carrot", "peas", "beans", "yogurt", "protein shake", "oats", "granola", "bacon", "sausage", "mushroom", "onion", "lettuce", "tomato", "mayonnaise", "sauce", "wrap", "roll", "sandwich"
    ]
    
    // MARK: - Permission Status Enum
    enum PermissionStatus {
        case notRequested
        case granted
        case denied
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
        print("📱 SpeechManager: Private init called")
        // Permissions will be requested explicitly from ContentView.onAppear
    }
    
    // MARK: - Permissions
    func requestPermissions() {
        print("📱 SpeechManager: Requesting permissions")
        
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            
            Task {
                if authStatus == .authorized {
                    // Request microphone permission
                    if #available(iOS 17.0, *) {
                        AVAudioApplication.requestRecordPermission { granted in
                            Task {
                                if granted {
                                    await MainActor.run {
                                        self.permissionStatus = .granted
                                        print("📱 SpeechManager: All permissions granted")
                                    }
                                } else {
                                    await MainActor.run {
                                        self.permissionStatus = .denied
                                        self.error = "Microphone access denied. Please enable in Settings."
                                    }
                                }
                            }
                        }
                    } else {
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            Task {
                                if granted {
                                    await MainActor.run {
                                        self.permissionStatus = .granted
                                        print("📱 SpeechManager: All permissions granted")
                                    }
                                } else {
                                    await MainActor.run {
                                        self.permissionStatus = .denied
                                        self.error = "Microphone access denied. Please enable in Settings."
                                    }
                                }
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        self.permissionStatus = .denied
                        self.error = "Speech recognition access denied. Please enable in Settings."
                    }
                }
            }
        }
    }
    
    func startRecording() {
        userStopped = false
        restartCount = 0
        startRecordingInternal()
    }
    
    private func startRecordingInternal() {
        guard permissionStatus == .granted else {
            error = "Permissions not granted."
            return
        }
        guard !audioEngine.isRunning else {
            error = "Audio engine already running."
            return
        }
        
        // iOS 26 specific safety check
        if #available(iOS 26.0, *) {
            print("📱 Starting recording on iOS 26 with enhanced safety")
            guard Thread.isMainThread else {
                print("⚠️ Moving to main thread for iOS 26 recording start")
                DispatchQueue.main.async {
                    self.startRecordingInternal()
                }
                return
            }
        }
        
        speechText = ""
        lastFinalSpeech = ""
        error = nil
        isRecording = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = "Failed to configure audio session: \(error.localizedDescription)"
            isRecording = false
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            error = "Failed to create recognition request."
            isRecording = false
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        // Add contextual hints for food terms
        if #available(iOS 13.0, *) {
            recognitionRequest.contextualStrings = foodContextualHints
        }
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            // Calculate audio level (RMS)
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let channelDataValueArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
            let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            self?.audioLevel = rms
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.error = "Failed to start audio engine: \(error.localizedDescription)"
            isRecording = false
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.speechText = result.bestTranscription.formattedString
                
                if result.isFinal {
                    self.lastFinalSpeech = result.bestTranscription.formattedString
                    // Cleanup after final result
                    self.recognitionTask?.cancel()
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.isRecording = false
                    do {
                        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                    } catch {}
                }
            }
            if let error = error {
                if let nsError = error as NSError? {
                    print("Speech recognition error: \(nsError.domain) code: \(nsError.code) desc: \(nsError.localizedDescription)")
                    if nsError.code == 1101 {
                        self.error = "Speech recognition is unavailable. Please check your permissions or try again later."
                        // Do NOT restart
                        self.isRecording = false
                        if self.audioEngine.isRunning {
                            self.audioEngine.stop()
                        }
                        self.audioEngine.inputNode.removeTap(onBus: 0)
                        do {
                            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {}
                        return
                    }
                    if !self.userStopped,
                       (nsError.domain == "kAFAssistantErrorDomain" || nsError.localizedDescription.lowercased().contains("canceled")),
                       self.restartCount < self.maxRestarts {
                        self.restartCount += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.startRecordingInternal()
                        }
                        return
                    }
                }
                self.error = error.localizedDescription
                // Always clean up before any restart or error
                self.recognitionTask?.cancel()
                self.recognitionRequest = nil
                self.recognitionTask = nil
                if self.audioEngine.isRunning {
                    self.audioEngine.stop()
                }
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.isRecording = false
                do {
                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                } catch {}
            }
        }
    }
    
    func stopRecording() {
        userStopped = true
        
        // Ensure proper cleanup order to prevent crashes
        recognitionRequest?.endAudio()
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Always remove tap before setting inactive
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        isRecording = false
        
        // Use a delay to ensure audio engine stops completely
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to deactivate audio session: \(error.localizedDescription)")
            }
        }
    }
    
    func reset() {
        stopRecording()
        speechText = ""
        lastFinalSpeech = ""
        error = nil
        permissionStatus = .notRequested
        audioLevel = 0.0
        restartCount = 0
        userStopped = false
    }
    
    // Add proper cleanup for app termination
    func cleanup() {
        print("🧹 SpeechManager: Starting cleanup")
        
        if isRecording {
            stopRecording()
        }
        
        // iOS 26 specific cleanup
        if #available(iOS 26.0, *) {
            print("📱 iOS 26 detected - using enhanced cleanup")
            // Ensure all audio resources are properly released
            DispatchQueue.main.async {
                self.performEnhancedCleanup()
            }
        } else {
            performStandardCleanup()
        }
    }
    
    private func performEnhancedCleanup() {
        // Enhanced cleanup for iOS 26 with better safety
        print("🧹 SpeechManager: Performing iOS 26 enhanced cleanup")
        
        // Cancel recognition task first
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        // Stop audio engine safely
        if audioEngine.isRunning {
            print("🔧 Stopping audio engine for iOS 26")
            audioEngine.stop()
        }
        
        // Remove tap with safety check
        if audioEngine.inputNode.numberOfInputs > 0 {
            print("🔧 Removing audio tap for iOS 26")
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // iOS 26 specific: Add small delay before audio session deactivation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                print("✅ Audio session deactivated successfully for iOS 26")
            } catch {
                print("⚠️ Failed to deactivate audio session on iOS 26: \(error.localizedDescription)")
            }
        }
        
        // Reset all state
        speechText = ""
        lastFinalSpeech = ""
        error = nil
        audioLevel = 0.0
        restartCount = 0
        userStopped = false
        isRecording = false
        
        print("🧹 SpeechManager: Enhanced cleanup completed for iOS 26")
    }
    
    private func performStandardCleanup() {
        // Standard cleanup for earlier iOS versions
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        speechRecognizer = nil
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        print("🧹 SpeechManager: Standard cleanup completed")
    }
    
    deinit {
        // Cannot call main-actor isolated cleanup() from synchronous deinit in Swift 6
        // Coordinate cleanup via ServiceManager or other mechanism if needed
    }
    
    func tryAgain() {
        stopRecording()
        error = nil
        startRecording()
    }
}
