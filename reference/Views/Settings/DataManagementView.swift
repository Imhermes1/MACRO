//
//  DataManagementView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct DataManagementView: View {
    @EnvironmentObject var dataManager: FoodDataManager
    @State private var showingImportSheet = false
    @State private var showingExportSheet = false
    @State private var showingClearDataAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Management")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Manage your nutrition data and backups")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Data Stats
            VStack(spacing: 16) {
                Text("Your Data")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    DataStatCard(
                        title: "Food Entries",
                        value: "\(dataManager.foodEntries.count)",
                        icon: "fork.knife"
                    )
                    
                    DataStatCard(
                        title: "Days Tracked",
                        value: "\(dataManager.daysTracked)",
                        icon: "calendar"
                    )
                }
                
                HStack {
                    DataStatCard(
                        title: "Total Calories",
                        value: "\(dataManager.totalCalories)",
                        icon: "flame"
                    )
                    
                    DataStatCard(
                        title: "Data Size",
                        value: "\(dataManager.dataSize)",
                        icon: "externaldrive"
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Data Actions
            VStack(spacing: 16) {
                Text("Data Actions")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SettingsButton(
                    title: "Export Data",
                    subtitle: "Download your nutrition data as CSV",
                    icon: "square.and.arrow.up",
                    action: { showingExportSheet = true }
                )
                
                SettingsButton(
                    title: "Import Data",
                    subtitle: "Import nutrition data from other apps",
                    icon: "square.and.arrow.down",
                    action: { showingImportSheet = true }
                )
                
                SettingsButton(
                    title: "Backup to iCloud",
                    subtitle: "Sync your data across devices",
                    icon: "icloud",
                    action: { dataManager.backupToiCloud() }
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Danger Zone
            VStack(spacing: 16) {
                Text("Danger Zone")
                    .foregroundColor(.red)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SettingsButton(
                    title: "Clear All Data",
                    subtitle: "Permanently delete all your food entries",
                    icon: "trash",
                    action: { showingClearDataAlert = true }
                )
                .foregroundColor(.red)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportDataView()
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportDataView()
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
                            Button("Clear All", role: .destructive) {
                    dataManager.clearAllEntries()
                }
        } message: {
            Text("This will permanently delete all your food entries. This action cannot be undone.")
        }
    }
}

struct DataStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ImportDataView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Import Data")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Import your nutrition data from other apps or CSV files.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    importOption("MyFitnessPal", icon: "square.and.arrow.down", description: "Import from MyFitnessPal export")
                    importOption("CSV File", icon: "doc.text", description: "Import from CSV file")
                    importOption("Health App", icon: "heart", description: "Import from Apple Health")
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func importOption(_ title: String, icon: String, description: String) -> some View {
        Button(action: {
            // TODO: Implement import
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FoodDataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Export Data")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Export your nutrition data in various formats.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    exportOption("CSV File", icon: "doc.text", description: "Export as CSV for spreadsheets")
                    exportOption("PDF Report", icon: "doc.richtext", description: "Generate a detailed PDF report")
                    exportOption("JSON Data", icon: "curlybraces", description: "Export raw data as JSON")
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportOption(_ title: String, icon: String, description: String) -> some View {
        Button(action: {
            // TODO: Implement export
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DataManagementView()
        .environmentObject(FoodDataManager())
} 