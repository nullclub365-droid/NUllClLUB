//
//  InsightDetailScreen.swift
//  SmartCart
//

import SwiftUI

struct InsightDetailScreen: View {
    @EnvironmentObject var store: AppStore
    let insightId: String
    var onBack: () -> Void
    var onRecipeSelected: ((Int64) -> Void)?

    private var content: InsightContent? { InsightRepository.content(forId: insightId) }

    var body: some View {
        Group {
            if let content = content {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        heroCard(content: content)
                        mainContentCard(content: content)
                        keyPointsCard(content: content)
                        BannerAdView()
                            .padding(.top, 8)
                        if let tips = content.tips, !tips.isEmpty {
                            practicalTipsCard(content: content, tips: tips)
                        }
                        if let benefits = content.benefits, !benefits.isEmpty {
                            benefitsCard(content: content, benefits: benefits)
                        }
                        if !content.relatedRecipeIds.isEmpty {
                            let related = content.relatedRecipeIds.compactMap { store.recipe(byId: $0) }
                            if !related.isEmpty {
                                relatedRecipesCard(recipes: related)
                            }
                        }
                        Spacer(minLength: 24)
                    }
                    .padding(20)
                }
            } else {
                ContentUnavailableView("Insight not found", systemImage: "lightbulb")
            }
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.primaryContainer.opacity(0.12),
                    AppTheme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Insight")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func heroCard(content: InsightContent) -> some View {
        VStack(spacing: 12) {
            Text(content.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.onPrimaryContainer)
                .lineSpacing(4)
            Text(content.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.onPrimaryContainer.opacity(0.85))
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppTheme.primaryContainer.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func mainContentCard(content: InsightContent) -> some View {
        let paragraphs = content.mainContent
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                Text(paragraph)
                    .font(.body)
                    .fontWeight(index == 0 ? .medium : .regular)
                    .lineSpacing(6)
                    .foregroundStyle(AppTheme.onSurface)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func keyPointsCard(content: InsightContent) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Key Points")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSecondaryContainer)
                    Text("What to remember")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSecondaryContainer.opacity(0.8))
                }
                Spacer()
            }
            ForEach(Array(content.keyPoints.enumerated()), id: \.offset) { index, point in
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.secondary)
                            .frame(width: 28, height: 28)
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    Text(point)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineSpacing(4)
                        .foregroundStyle(AppTheme.onSecondaryContainer)
                }
            }
        }
        .padding(20)
        .background(AppTheme.secondaryContainer.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func practicalTipsCard(content: InsightContent, tips: [String]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.tertiary.opacity(0.3))
                        .frame(width: 48, height: 48)
                    Image(systemName: "lightbulb.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.tertiary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Practical Tips")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onTertiaryContainer)
                    Text("Try these in your daily routine")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onTertiaryContainer.opacity(0.9))
                }
                Spacer()
            }
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.tertiary)
                            .frame(width: 32, height: 32)
                        Text("\(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    Text(tip)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineSpacing(4)
                        .foregroundStyle(AppTheme.onTertiaryContainer)
                }
            }
        }
        .padding(24)
        .background(AppTheme.tertiaryContainer.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.tertiary.opacity(0.15), radius: 6, x: 0, y: 3)
    }

    private func benefitsCard(content: InsightContent, benefits: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.primary)
                Text("Benefits")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onPrimaryContainer)
                Spacer()
            }
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.primary.opacity(0.25))
                            .frame(width: 28, height: 28)
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.primary)
                    }
                    Text(benefit)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineSpacing(4)
                        .foregroundStyle(AppTheme.onPrimaryContainer)
                }
            }
        }
        .padding(20)
        .background(AppTheme.primaryContainer.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func relatedRecipesCard(recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Try These Recipes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("Picked for this insight")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recipes) { recipe in
                        recipeCard(recipe: recipe)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func recipeCard(recipe: Recipe) -> some View {
        Button(action: { onRecipeSelected?(recipe.id) }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    if let tag = recipe.tags.first {
                        Text(tag.capitalized)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.primaryContainer.opacity(0.45))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.6))
                }
                Spacer()
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondary)
                    Text("\(recipe.calories) kcal")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
            .frame(width: 150, height: 110)
            .padding(14)
            .background(AppTheme.surfaceVariant.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func iconName(for id: String) -> String {
        InsightRepository.all.first { $0.id == id }?.iconName ?? "lightbulb.fill"
    }
}

#Preview {
    NavigationStack {
        InsightDetailScreen(insightId: "oily_fish", onBack: {})
            .environmentObject(AppStore())
    }
}
