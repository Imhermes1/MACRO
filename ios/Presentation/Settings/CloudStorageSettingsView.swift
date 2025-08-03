import SwiftUI

struct CloudStorageSettingsView: View {
    @State private var selectedProvider: CloudProvider = .localOnly
    @State private var availableProviders: [CloudProvider] = []
    @State private var cloudKitStatus = "Checking..."
    @State private var showingInfo = false
    
    private let profileRepo = UserProfileRepository()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile Storage Options")) {
                    ForEach(availableProviders, id: \.self) { (provider: CloudProvider) in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(provider.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(provider.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if selectedProvider == provider {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectProvider(provider)
                        }
                    }
                }
                
                if availableProviders.contains(.cloudKit) {
                    Section(header: Text("iCloud Status")) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text(cloudKitStatus)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("About Cloud Storage")) {
                    Button("Learn More") {
                        showingInfo = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Cloud Storage")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        // Handle dismiss
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
                checkAvailableProviders()
                checkCloudKitStatus()
            }
            .sheet(isPresented: $showingInfo) {
                CloudStorageInfoView()
            }
        }
    }
    
    private func loadCurrentSettings() {
        if let providerString = profileRepo.getCurrentCloudProvider(),
           let provider = CloudProvider(rawValue: providerString) {
            selectedProvider = provider
        }
    }
    
    private func checkAvailableProviders() {
        let providers = profileRepo.getAvailableCloudProviders()
        availableProviders = providers as! [CloudProvider]
    }
    
    private func checkCloudKitStatus() {
        let cloudKitRepo = CloudKitUserProfileRepository()
        cloudKitRepo.checkCloudKitStatus { status in
            self.cloudKitStatus = status
        }
    }
    
    private func selectProvider(_ provider: CloudProvider) {
        selectedProvider = provider
        profileRepo.setCloudProvider(provider.rawValue)
    }
}

struct CloudStorageInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📱 Local Only")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Your profile stays on this device only. Perfect for privacy-conscious users or if you don't want cloud sync.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("☁️ iCloud (CloudKit)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Uses Apple's native cloud service. Syncs across all your Apple devices automatically. Requires being signed into iCloud.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("✓ Most private and secure\n✓ Seamless Apple ecosystem integration\n✓ No additional accounts needed")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("�️ Supabase")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Cross-platform cloud storage. Works across iOS, Android, and web. Best for sharing data between different device types.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("✓ Works across all platforms\n✓ Reliable and fast\n✓ Great for multi-platform users")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Spacer(minLength: 20)
                    
                    Text("You can change this setting anytime. Your data will be migrated safely between storage options.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Cloud Storage Options")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

