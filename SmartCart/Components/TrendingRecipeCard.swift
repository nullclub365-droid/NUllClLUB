//
//  TrendingRecipeCard.swift
//  SmartCart
//

import SwiftUI

struct TrendingRecipeCard: View {
    let title: String
    let emoji: String
    let badge: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(emoji)
                        .font(.system(size: 32))
                    Spacer()
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.secondary)
                        .clipShape(Capsule())
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("4.8")
                        .font(.caption)
                    Spacer()
                }
                .foregroundStyle(AppTheme.secondary)
            }
            .padding(12)
            .frame(width: 140)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.08), radius: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TrendingRecipeCard(title: "Buddha Bowl", emoji: "🥗", badge: "Trending", action: {})
        .padding()
        .background(AppTheme.background)
}
