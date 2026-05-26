//
//  EmptyStateView.swift
//  SmartCart
//

import SwiftUI

struct EmptyStateView: View {
    var icon: String = "tray"
    var title: String = "Nothing here"
    var message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primary.opacity(0.6))
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary)
                        .clipShape(Capsule())
                }
                .accessibilityActionLabel(actionTitle, hint: "Double tap to \(actionTitle.lowercased())")
                .accessibilityTouchTarget()
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

#Preview {
    EmptyStateView(
        message: "Add items to get started.",
        actionTitle: "Add item",
        action: {}
    )
}
