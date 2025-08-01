//
//  ServiceManager.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Service Manager for Lazy Loading
@MainActor
final class ServiceManager: ObservableObject {
    private static var _shared: ServiceManager?
    
    static var shared: ServiceManager {
        if _shared == nil {
            print("🔧 ServiceManager: Lazy initialization")
            _shared = ServiceManager()
        }
        return _shared!
    }
    
    init() {
        print("🔧 ServiceManager: Init called")
    }
    
    // MARK: - Lazy-loaded services
    private var _speechManager: SpeechManager?
    
    var speechManager: SpeechManager {
        if _speechManager == nil {
            print("🎤 ServiceManager: Lazy-loading SpeechManager")
            // iOS 26 Safe: Ensure we're on main thread
            assert(Thread.isMainThread, "SpeechManager must be accessed from main thread")
            _speechManager = SpeechManager.shared
        }
        return _speechManager!
    }
    
    // MARK: - Memory Management
    func preloadCriticalServices() {
        // Only preload services that are essential at startup
        print("🚀 ServiceManager: Preloading critical services")
        // Don't preload SpeechManager - it's heavy and not always needed
    }
    
    func clearNonEssentialServices() {
        // Clear services that can be reloaded when needed
        print("🧹 ServiceManager: Clearing non-essential services")
        
        // Clear SpeechManager if it's been loaded
        if let speechManager = _speechManager {
            Task { @MainActor in
                speechManager.cleanup()
            }
            // In production, coordinate cleanup with UI lifecycle. For now, we always nil out the manager.
            _speechManager = nil
        }
    }
    
    deinit {
        // Clear services synchronously during deinit to avoid capturing self in a task
        if _speechManager != nil {
            // Note: We can't use async cleanup in deinit, so we'll just nil out the reference
            // The SpeechManager's own deinit will handle its cleanup
            _speechManager = nil
        }
    }
}

// MARK: - Environment Key for ServiceManager
struct ServiceManagerKey: EnvironmentKey {
    static var defaultValue: ServiceManager {
        // Create a new instance to avoid recursion
        return ServiceManager()
    }
}

extension EnvironmentValues {
    var serviceManager: ServiceManager {
        get { self[ServiceManagerKey.self] }
        set { self[ServiceManagerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func withServiceManager() -> some View {
        self.environmentObject(ServiceManager.shared)
    }
}
