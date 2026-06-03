//
//  ChallengeCard.swift
//  SmartCart
//

import SwiftUI

struct ChallengeCard: View {
    let title: String
    let description: String
    let progress: Double
    let count: String
    let icon: String
    let color: Color

    var isCompleted: Bool {
        progress >= 1.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        Spacer()
                        if isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                Text("Done!")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(AppTheme.primary)
                        }
                    }
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
            }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.surfaceVariant.opacity(0.5))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity * progress, alignment: .leading)
                    .frame(height: 6)
            }

            HStack {
                Text(count)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ChallengeCard(
        title: "Plan 7 Meals",
        description: "Plan every meal for this week",
        progress: 0.57,
        count: "4/7",
        icon: "📋",
        color: AppTheme.primary
    )
    .padding()
    .background(AppTheme.background)
}
