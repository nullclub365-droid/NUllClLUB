//
//  CelebrationModal.swift
//  SmartCart
//

import SwiftUI

struct CelebrationModal: View {
    let title: String
    let subtitle: String
    let icon: String
    let confettiEmojis: [String]
    var onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Confetti background
                    ZStack {
                        ForEach(0..<confettiEmojis.count, id: \.self) { index in
                            Text(confettiEmojis[index % confettiEmojis.count])
                                .font(.system(size: CGFloat.random(in: 20...40)))
                                .offset(
                                    x: CGFloat.random(in: -120...120),
                                    y: CGFloat.random(in: -120...120)
                                )
                                .opacity(Double.random(in: 0.4...0.8))
                        }
                    }
                    .frame(height: 200)

                    // Main celebration card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Text(icon)
                                .font(.system(size: 48))
                        }
                        .scaleEffect(scale)

                        VStack(spacing: 8) {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.onSurface)

                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(30)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    CelebrationModal(
        title: "Congrats! 🎉",
        subtitle: "You planned your first week of meals!",
        icon: "🎉",
        confettiEmojis: ["🎉", "⭐", "🎊", "✨"],
        onDismiss: {}
    )
    .background(AppTheme.background)
}
