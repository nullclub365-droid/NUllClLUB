//
//  LegalContent.swift
//  SmartCart
//

import Foundation

struct LegalSection {
    let title: String
    let paragraphs: [String]
}

enum LegalContent {
    /// SmartCart Privacy Policy – use this URL in App Store Connect and for "View online" in-app.
    static let privacyPolicyURLString = "https://nullclub365-droid.github.io/SmartCart/"
    static var privacyPolicyURL: URL? { URL(string: privacyPolicyURLString) }

    static var termsOfService: [LegalSection] {
        [
            LegalSection(title: "1. Acceptance of Terms", paragraphs: [
                "By downloading, installing, or using SmartCart (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App."
            ]),
            LegalSection(title: "2. Description of Service", paragraphs: [
                "SmartCart is a mobile application that helps users manage recipes, meal planning, grocery lists, and nutrition tracking. The App operates entirely offline and stores all data locally on your device."
            ]),
            LegalSection(title: "3. User Responsibilities", paragraphs: [
                "You are responsible for: maintaining the security of your device; backing up your data regularly; using the App in accordance with applicable laws; providing accurate information; and not using the App for any unlawful purpose."
            ]),
            LegalSection(title: "4. Data and Privacy", paragraphs: [
                "All data entered into the App is stored locally on your device. The App does not collect, transmit, or store your personal data on external servers. You are solely responsible for backing up your data. For detailed information about data handling, please review our Privacy Policy."
            ]),
            LegalSection(title: "5. Intellectual Property", paragraphs: [
                "The App and its original content, features, and functionality are owned by SmartCart and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws. You may not copy, modify, distribute, sell, or lease any part of the App or included software."
            ]),
            LegalSection(title: "6. Nutrition and Health Information", paragraphs: [
                "Nutrition information provided in the App is for informational purposes only and should not be considered medical or nutritional advice. Always consult with a healthcare professional or registered dietitian before making significant changes to your diet.",
                "Recipe calories and protein are stored per recipe and are intended to give you a helpful estimate for meal planning and tracking—generally within a reasonable range—but are not guaranteed to be exact. Portion sizes, cooking methods, and ingredient brands can vary, so use these numbers as a guide rather than for medical or clinical purposes. The App is not responsible for any health outcomes resulting from the use of this information."
            ]),
            LegalSection(title: "7. Recipe Content", paragraphs: [
                "Recipes and cooking instructions are for general informational purposes. You are responsible for following safe food handling practices, checking for food allergies and dietary restrictions, and ensuring ingredients are fresh and properly stored. The App is not responsible for any foodborne illness or adverse reactions resulting from following recipes or cooking instructions."
            ]),
            LegalSection(title: "8. Limitation of Liability", paragraphs: [
                "To the maximum extent permitted by law, SmartCart and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses resulting from your use of the App."
            ]),
            LegalSection(title: "9. Warranty Disclaimer", paragraphs: [
                "The App is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, secure, or error-free."
            ]),
            LegalSection(title: "10. Modifications and Termination", paragraphs: [
                "We reserve the right to modify, suspend, or discontinue the App at any time with or without notice. We may terminate or suspend your access immediately, without prior notice, for any reason, including if you breach these Terms."
            ]),
            LegalSection(title: "11. Governing Law & Contact", paragraphs: [
                "These Terms shall be governed by the laws of the jurisdiction in which the App is distributed. If you have any questions about these Terms of Service, please contact us through the App's support channels or settings menu."
            ])
        ]
    }

    static var privacyPolicy: [LegalSection] {
        [
            LegalSection(title: "1. Introduction", paragraphs: [
                "SmartCart (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our mobile application (\"the App\")."
            ]),
            LegalSection(title: "2. Data Storage – Local Only", paragraphs: [
                "SmartCart is designed as an offline-first application. All user-generated data you enter into the App, including recipes and meal plans, grocery lists and pantry items, nutrition tracking data, user preferences and settings, and cooking history and notes, is stored exclusively on your device. We do not collect, transmit, store, or process any of your personal content data on external servers or cloud services."
            ]),
            LegalSection(title: "3. Firebase Analytics & Telemetry", paragraphs: [
                "To improve the App and understand usage patterns, we use Google Firebase Analytics to collect anonymized analytics data. This includes: app usage statistics, feature interaction data, crash reports and performance metrics, and anonymous device information. Firebase Analytics collects this data in accordance with Google's privacy policies. No personal information (names, emails, phone numbers) is collected through analytics. You can opt out of analytics collection through your device settings.",
                "Crash reports collected by Firebase may include device model, OS version, app version, and stack traces from crashes. This information helps us identify and fix bugs. No user content or personal data is included in crash reports.",
                "We also use Firebase for: In-App Messaging to show helpful tips and notifications, and Remote Configuration to manage app features and update settings without requiring app updates. Data retention for Firebase Analytics is typically 14 months; for more details, see Google's data retention policies."
            ]),
            LegalSection(title: "4. Advertising", paragraphs: [
                "SmartCart displays ads through Google AdMob. Google AdMob may collect and process information for personalized advertising purposes in accordance with Google's privacy policies. This includes limited information about your app usage, general device information, and your advertising ID (which you can reset in your device settings). Personalized ads are limited by your ad preferences and app-tracking transparency settings.",
                "For iOS users: We request Apple's App Tracking Transparency (ATT) permission at app launch. You can grant or deny tracking permission at any time through your device settings. If you deny ATT, ads will be shown but not personalized."
            ]),
            LegalSection(title: "4.5. Push Notifications", paragraphs: [
                "If you enable notifications, we may send you: meal preparation reminders based on your meal planner, expiry alerts for pantry items, and engagement tips. Notification data is processed locally on your device. You can disable notifications at any time through your device settings or the App settings."
            ]),
            LegalSection(title: "5. Location Data", paragraphs: [
                "SmartCart does not collect, request, or process your location data. The App has no access to your GPS, location services, or any location-based information."
            ]),
            LegalSection(title: "6. In-App Purchases", paragraphs: [
                "SmartCart offers a Premium subscription through Apple's App Store. All payment processing is handled by Apple in accordance with Apple's privacy policies. We do not collect, store, or process your payment card information. Transaction receipts and subscription status are managed by Apple. You can manage your subscriptions and billing information through your Apple ID settings."
            ]),
            LegalSection(title: "7. External Content & Assets", paragraphs: [
                "Recipe images are loaded from an external GitHub repository (https://raw.githubusercontent.com/nullclub365-droid/smartcart-assets/). When you view recipes, your device connects to GitHub to fetch these images. GitHub's privacy policy applies to this data. Your personal information is not shared with GitHub; only your request to view a recipe image is sent. You can disable image loading in your device's network settings if desired."
            ]),
            LegalSection(title: "8. Permissions", paragraphs: [
                "The App may request certain permissions on your device, including: Notifications for reminders and meal notifications, Storage for backup and data export, and App Tracking Transparency (ATT) on iOS for limited personalized advertising. These permissions are optional and only used when you explicitly enable the related features. You can revoke them at any time through your device settings."
            ]),
            LegalSection(title: "9. Data Backup", paragraphs: [
                "If you use the backup and restore feature, your data export file is created and stored on your device or a location you choose. We do not have access to these backup files. You are responsible for securing and managing your backup files."
            ]),
            LegalSection(title: "10. Data Security", paragraphs: [
                "Since your content data is stored locally on your device, data security depends on your device's security measures. We recommend using device lock screens, keeping your OS updated, and regularly backing up your data using the App's backup feature. Analytics and ad data sent to Google services are protected by Google's security measures."
            ]),
            LegalSection(title: "11. Data Deletion", paragraphs: [
                "You can delete your local data at any time by uninstalling the App (which removes all local data), using the App's data deletion features in settings, or clearing the App's data through your device settings. Once deleted, local data cannot be recovered unless you have a backup. Analytics data is managed by Google; refer to their privacy policies for deletion requests."
            ]),
            LegalSection(title: "12. Your Rights & Choices", paragraphs: [
                "You have complete control over your content data because it's stored on your device. You can view, modify, export, or delete any of your content data at any time. For analytics and ad data collected by Google services, you can: disable analytics collection in app settings, opt out of personalized ads through your device settings, and reset your advertising ID in your device settings.",
                "For users in California (CCPA): You have the right to know what personal information is collected and how it's used. Since we don't collect personal information (only anonymized analytics), your rights are limited. For users in the EU (GDPR): We comply with GDPR principles by minimizing data collection and providing transparency."
            ]),
            LegalSection(title: "13. Third-Party Services", paragraphs: [
                "SmartCart uses the following third-party services that may collect data in accordance with their own privacy policies: Google Firebase (analytics, crash reporting, in-app messaging), Google AdMob (advertising), Google User Messaging Platform (consent management), Apple App Store (in-app purchases), and GitHub (recipe images). Please review their privacy policies for details: Google (https://policies.google.com/privacy), Apple (https://www.apple.com/privacy/), and GitHub (https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement)"
            ]),
            LegalSection(title: "14. Children's Privacy", paragraphs: [
                "The App is not intended for children under 13. We do not knowingly collect personal information from children. Parents or guardians who believe their child has provided personal information should contact us immediately."
            ]),
            LegalSection(title: "15. Contact & Privacy Questions", paragraphs: [
                "If you have questions about this Privacy Policy, concerns about your privacy, or requests to exercise your rights, please contact us at: support@smartcart.app or through the App's contact form in the Settings menu. We will respond to privacy inquiries within 30 days."
            ]),
            LegalSection(title: "16. Changes to Privacy Policy", paragraphs: [
                "We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. We will notify you of any material changes by updating the \"Last Updated\" date in the App and, if required, by displaying a notice in the App or through other means. Your continued use of the App after changes constitutes your acceptance of the updated Privacy Policy. We recommend reviewing this policy periodically to stay informed about how we protect your privacy.",
                "Effective Date: January 1, 2025"
            ])
        ]
    }
}
