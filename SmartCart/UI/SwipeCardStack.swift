//
//  SwipeCardStack.swift
//  SmartCart
//

import SwiftUI

struct SwipeCardStack<Item: Identifiable, CardContent: View>: View {
    let items: [Item]
    let onSwipeLeft: (Item) -> Void
    let onSwipeRight: (Item) -> Void

    var rightLabel: String = "ADD"
    var leftLabel: String = "SKIP"
    var rightIcon: String = "checkmark.circle.fill"
    var leftIcon: String = "xmark.circle.fill"

    @ViewBuilder let cardContent: (Item) -> CardContent

    @State private var dragOffset: CGSize = .zero
    @State private var dragRotation: Double = 0
    @State private var isAnimating = false

    private let threshold: CGFloat = 110

    private var topItem: Item? { items.first }
    private var secondItem: Item? { items.dropFirst().first }
    private var thirdItem: Item? { items.dropFirst(2).first }

    var body: some View {
        ZStack {
            if let third = thirdItem {
                cardContent(third)
                    .scaleEffect(0.90)
                    .offset(y: 24)
                    .opacity(0.5)
                    .allowsHitTesting(false)
            }
            if let second = secondItem {
                cardContent(second)
                    .scaleEffect(0.95)
                    .offset(y: 12)
                    .opacity(0.75)
                    .allowsHitTesting(false)
            }
            if let top = topItem {
                cardContent(top)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(dragRotation))
                    .overlay(alignment: .leading) { leftLabelView }
                    .overlay(alignment: .trailing) { rightLabelView }
                    .gesture(dragGesture(for: top))
                    .id(top.id)
            }
        }
    }

    private var rightLabelView: some View {
        VStack(spacing: 4) {
            Image(systemName: rightIcon)
                .font(.system(size: 40))
                .foregroundStyle(.white)
            Text(rightLabel)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .tracking(1.5)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(20)
        .opacity(min(1.0, Double(max(0, dragOffset.width)) / 80.0))
        .allowsHitTesting(false)
    }

    private var leftLabelView: some View {
        VStack(spacing: 4) {
            Image(systemName: leftIcon)
                .font(.system(size: 40))
                .foregroundStyle(.white)
            Text(leftLabel)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .tracking(1.5)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 1.0, green: 0.2, blue: 0.2).opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(20)
        .opacity(min(1.0, Double(max(0, -dragOffset.width)) / 80.0))
        .allowsHitTesting(false)
    }

    private func dragGesture(for item: Item) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isAnimating else { return }
                dragOffset = value.translation
                dragRotation = Double(value.translation.width) / 22.0
            }
            .onEnded { value in
                guard !isAnimating else { return }
                if value.translation.width > threshold {
                    fly(item: item, direction: .right)
                } else if value.translation.width < -threshold {
                    fly(item: item, direction: .left)
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = .zero
                        dragRotation = 0
                    }
                }
            }
    }

    private enum Direction { case left, right }

    private func fly(item: Item, direction: Direction) {
        isAnimating = true
        Haptics.light()
        let tx: CGFloat = direction == .right ? 700 : -700
        let rot: Double = direction == .right ? 30 : -30
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = CGSize(width: tx, height: dragOffset.height * 0.4)
            dragRotation = rot
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dragOffset = .zero
            dragRotation = 0
            isAnimating = false
            if direction == .right {
                onSwipeRight(item)
            } else {
                onSwipeLeft(item)
            }
        }
    }
}

// MARK: - Shared category styling helpers

func categoryColors(_ category: String) -> (Color, Color) {
    switch category.lowercased() {
    case "dairy":
        return (Color(red: 0.70, green: 0.85, blue: 0.98), Color(red: 0.45, green: 0.70, blue: 0.90))
    case "meat":
        return (Color(red: 0.92, green: 0.55, blue: 0.55), Color(red: 0.75, green: 0.30, blue: 0.30))
    case "poultry":
        return (Color(red: 0.95, green: 0.72, blue: 0.50), Color(red: 0.82, green: 0.52, blue: 0.28))
    case "produce", "vegetables", "vegetable":
        return (Color(red: 0.60, green: 0.85, blue: 0.60), Color(red: 0.35, green: 0.70, blue: 0.40))
    case "fruits", "fruit":
        return (Color(red: 0.98, green: 0.78, blue: 0.45), Color(red: 0.90, green: 0.55, blue: 0.25))
    case "grains", "bread", "grain", "bakery":
        return (Color(red: 0.90, green: 0.82, blue: 0.65), Color(red: 0.75, green: 0.65, blue: 0.42))
    case "seafood", "fish":
        return (Color(red: 0.55, green: 0.78, blue: 0.95), Color(red: 0.30, green: 0.58, blue: 0.85))
    case "beverages", "beverage", "drinks":
        return (Color(red: 0.78, green: 0.65, blue: 0.95), Color(red: 0.55, green: 0.42, blue: 0.85))
    case "condiments", "sauces", "condiment":
        return (Color(red: 0.95, green: 0.82, blue: 0.45), Color(red: 0.85, green: 0.65, blue: 0.25))
    case "frozen":
        return (Color(red: 0.72, green: 0.88, blue: 0.95), Color(red: 0.48, green: 0.72, blue: 0.90))
    case "spices", "herbs", "spice":
        return (Color(red: 0.92, green: 0.65, blue: 0.50), Color(red: 0.78, green: 0.42, blue: 0.32))
    case "oils", "oil", "fats":
        return (Color(red: 0.95, green: 0.88, blue: 0.55), Color(red: 0.82, green: 0.72, blue: 0.32))
    case "nuts", "seeds", "nut":
        return (Color(red: 0.82, green: 0.72, blue: 0.55), Color(red: 0.65, green: 0.55, blue: 0.38))
    case "legumes", "beans", "legume":
        return (Color(red: 0.72, green: 0.78, blue: 0.60), Color(red: 0.52, green: 0.60, blue: 0.38))
    default:
        return (Color(red: 0.30, green: 0.69, blue: 0.58), Color(red: 0.20, green: 0.55, blue: 0.45))
    }
}

func categoryEmoji(_ category: String) -> String {
    switch category.lowercased() {
    case "dairy": return "🥛"
    case "meat": return "🥩"
    case "poultry": return "🍗"
    case "produce", "vegetables", "vegetable": return "🥦"
    case "fruits", "fruit": return "🍎"
    case "grains", "bread", "grain", "bakery": return "🌾"
    case "seafood", "fish": return "🐟"
    case "beverages", "beverage", "drinks": return "🥤"
    case "condiments", "sauces", "condiment": return "🫙"
    case "frozen": return "🧊"
    case "spices", "herbs", "spice": return "🌶️"
    case "oils", "oil", "fats": return "🫒"
    case "nuts", "seeds", "nut": return "🥜"
    case "legumes", "beans", "legume": return "🫘"
    default: return "🛒"
    }
}
