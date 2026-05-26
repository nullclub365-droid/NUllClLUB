//
//  BackupScreen.swift
//  SmartCart
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// Catalog file exported from Android (ingredients + recipes) for iOS import.
struct RecipeCatalogFile: Codable {
    let ingredients: [Ingredient]
    let recipes: [Recipe]
}

struct BackupScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    @State private var isExporting = false
    @State private var shareItem: ShareableURL?
    @State private var message: String?
    @State private var showImporter = false
    @State private var showCatalogImporter = false
    @State private var pendingBackup: BackupData?
    @State private var showRestoreChoice = false

    private struct ShareableURL: Identifiable {
        let id = UUID()
        let url: URL
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Backup & Restore")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)

                if let err = store.lastPersistenceError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurface)
                        Spacer()
                        Button("Dismiss") {
                            store.lastPersistenceError = nil
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.primary)
                    }
                    .padding(12)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                createBackupCard
                importCatalogCard
                restoreBackupCard
                if let message = message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(message.contains("success") ? AppTheme.primary : .red)
                }
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Backup")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
        .fileImporter(isPresented: $showCatalogImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    message = "Could not access file."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let data = try Data(contentsOf: url)
                    let catalog = try JSONDecoder().decode(RecipeCatalogFile.self, from: data)
                    store.importCatalog(ingredients: catalog.ingredients, recipes: catalog.recipes)
                    message = "Catalog imported: \(catalog.ingredients.count) ingredients, \(catalog.recipes.count) recipes."
                } catch {
                    message = "Invalid catalog file: \(error.localizedDescription)"
                }
            case .failure(let err):
                message = "Could not open file: \(err.localizedDescription)"
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    message = "Could not access file."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let data = try Data(contentsOf: url)
                    let backup = try JSONDecoder().decode(BackupData.self, from: data)
                    pendingBackup = backup
                    showRestoreChoice = true
                } catch {
                    message = "Invalid backup file: \(error.localizedDescription)"
                }
            case .failure(let err):
                message = "Could not open file: \(err.localizedDescription)"
            }
        }
        .confirmationDialog("Restore backup", isPresented: $showRestoreChoice, titleVisibility: .visible) {
            Button("Replace all data", role: .destructive) {
                if let backup = pendingBackup {
                    store.restore(from: backup)
                    message = "Restore successful. Your data has been replaced."
                }
                pendingBackup = nil
            }
            Button("Merge with existing") {
                if let backup = pendingBackup {
                    store.merge(from: backup)
                    message = "Merge successful. Backup data was added to your existing data."
                }
                pendingBackup = nil
            }
            Button("Cancel", role: .cancel) {
                pendingBackup = nil
            }
        } message: {
            Text("Replace overwrites all current data (meal plan, groceries, pantry, nutrition, favorites, collections). Merge adds backup items without removing what you have. You can export a backup first if you want to keep a copy.")
        }
    }

    private var createBackupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
                Text("Create Backup")
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
            }
            Text("Export your data (pantry, groceries, favorites, meal prep, nutrition, history) to a JSON file.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            Button(action: createBackup) {
                if isExporting {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Create Backup")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
            .disabled(isExporting)
            .accessibilityActionLabel("Create Backup", descriptive: "Export your data to a JSON file", hint: "Double tap to export")
            .accessibilityTouchTarget()
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var importCatalogCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.tertiary)
                Text("Import recipe catalog")
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
            }
            Text("Import the recipe catalog JSON exported from the Android app to get all your recipes and ingredients on iOS.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            Button("Choose catalog file…") {
                showCatalogImporter = true
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.primary)
            .accessibilityActionLabel("Choose catalog file", descriptive: "Import recipe catalog from Android", hint: "Double tap to select file")
            .accessibilityTouchTarget()
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var restoreBackupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundStyle(AppTheme.secondary)
                Text("Restore Backup")
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
            }
            Text("Import a previously exported JSON backup file (pantry, groceries, favorites, etc.).")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            Button("Choose file…") {
                showImporter = true
            }
            .accessibilityActionLabel("Choose file", descriptive: "Import a backup file to restore data", hint: "Double tap to select file")
            .accessibilityTouchTarget()
            .buttonStyle(.bordered)
            .tint(AppTheme.primary)
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func createBackup() {
        isExporting = true
        message = nil
        defer { isExporting = false }
        let data = BackupData(from: store)
        guard let encoded = try? JSONEncoder().encode(data) else {
            message = "Encode failed."
            return
        }
        let fileName = "SmartCartBackup_\(ISO8601DateFormatter().string(from: Date()).prefix(19).replacingOccurrences(of: ":", with: "-")).json"
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try encoded.write(to: temp)
            shareItem = ShareableURL(url: temp)
            message = "Backup created. Share/save the file."
        } catch {
            message = "Write failed: \(error.localizedDescription)"
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct BackupData: Codable {
    var pantry: [PantryItem]
    var grocery: [GroceryItem]
    var favoriteRecipeIds: [Int64]
    var mealPrepRecipeIds: [Int64]
    var nutritionEntries: [DailyNutritionEntry]
    var recipeHistory: [RecipeHistoryItem]
    var recipeNotes: [BackupRecipeNote]?
    var recipeRatings: [BackupRecipeRating]?
    var recentRecipeSearches: [String]?
    var allergies: [String]?
    var dietPreferences: [String]?
    var healthGoals: [String]?
    var recipeCollections: [BackupRecipeCollection]?
    var customMeals: [CustomMeal]?
    var exportedAt: String

    struct BackupRecipeNote: Codable {
        var recipeId: Int64
        var note: String
    }

    struct BackupRecipeRating: Codable {
        var recipeId: Int64
        var rating: Int
    }

    struct BackupRecipeCollection: Codable {
        var id: Int64
        var name: String
        var recipeIds: [Int64]
    }

    init(from store: AppStore) {
        pantry = store.pantryItems
        grocery = store.groceryItems
        favoriteRecipeIds = Array(store.favoriteRecipeIds)
        mealPrepRecipeIds = store.mealPrepRecipeIds
        nutritionEntries = store.nutritionEntries
        recipeHistory = store.recipeHistory
        recipeNotes = store.recipeNotes.map { BackupRecipeNote(recipeId: $0.key, note: $0.value) }
        recipeRatings = store.recipeRatings.isEmpty ? nil : store.recipeRatings.map { BackupRecipeRating(recipeId: $0.key, rating: $0.value) }
        recentRecipeSearches = store.recentRecipeSearches.isEmpty ? nil : store.recentRecipeSearches
        allergies = store.allergies.isEmpty ? nil : store.allergies
        dietPreferences = store.dietPreferences.isEmpty ? nil : store.dietPreferences
        healthGoals = store.healthGoals.isEmpty ? nil : store.healthGoals
        recipeCollections = store.recipeCollections.isEmpty ? nil : store.recipeCollections.map { BackupRecipeCollection(id: $0.id, name: $0.name, recipeIds: $0.recipeIds) }
        customMeals = store.customMeals.isEmpty ? nil : store.customMeals
        exportedAt = ISO8601DateFormatter().string(from: Date())
    }
}

#Preview {
    NavigationStack {
        BackupScreen(onBack: {})
            .environmentObject(AppStore())
    }
}
