//
//  AppTheme.swift
//  SmartCart
//

import SwiftUI
import UIKit

enum AppTheme {
    // Brand colors – same in light and dark
    static let primary = Color(red: 0.30, green: 0.69, blue: 0.58)       // #4CAF93
    static let secondary = Color(red: 0.95, green: 0.64, blue: 0.40)     // #F2A365
    static let tertiary = Color(red: 0.35, green: 0.49, blue: 0.75)      // #5A7DBE

    // Adaptive colors – resolve for light/dark
    static let primaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.32, blue: 0.28, alpha: 1)
            : UIColor(red: 0.90, green: 0.96, blue: 0.94, alpha: 1)
    })
    static let onPrimaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.75, green: 0.92, blue: 0.88, alpha: 1)
            : UIColor(red: 0.06, green: 0.24, blue: 0.18, alpha: 1)
    })

    static let secondaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1)
            : UIColor(red: 1.0, green: 0.95, blue: 0.90, alpha: 1)
    })
    static let onSecondaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1)
            : UIColor(red: 0.22, green: 0.18, blue: 0.12, alpha: 1)
    })

    static let tertiaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.22, blue: 0.38, alpha: 1)
            : UIColor(red: 0.89, green: 0.91, blue: 0.94, alpha: 1)
    })
    static let onTertiaryContainer = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.85, green: 0.88, blue: 0.96, alpha: 1)
            : UIColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1)
    })

    static let surface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1)
            : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    })
    static let onSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
            : UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)
    })
    static let onSurfaceVariant = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.72, green: 0.72, blue: 0.74, alpha: 1)
            : UIColor(red: 0.37, green: 0.39, blue: 0.41, alpha: 1)
    })
    static let surfaceVariant = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.22, blue: 0.24, alpha: 1)
            : UIColor(red: 0.93, green: 0.94, blue: 0.94, alpha: 1)
    })

    static let background = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1)
            : UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1)
    })
    static let outline = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1)
            : UIColor(red: 0.85, green: 0.86, blue: 0.88, alpha: 1)
    })
}
