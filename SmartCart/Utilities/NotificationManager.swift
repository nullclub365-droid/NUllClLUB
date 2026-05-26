//
//  NotificationManager.swift
//  SmartCart
//

import UserNotifications
import Foundation
import Combine
import UIKit

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval = 86400, badge: NSNumber = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = badge

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleEngagementNotifications(store: AppStore) {
        guard isAuthorized else { return }

        let cookedCount = store.recipeHistory.count
        let pantryCount = store.pantryItems.count

        // Engagement notification after 1 day
        if cookedCount == 0 {
            scheduleLocalNotification(
                title: "Time to cook! 👨‍🍳",
                body: "Pick a recipe from our 415+ collection and cook your first meal.",
                delay: 86400
            )
        }

        // Encouragement notification after 3 days
        if cookedCount > 0 && cookedCount < 3 {
            scheduleLocalNotification(
                title: "You're on a roll! 🔥",
                body: "Cook 3 recipes to unlock the 'Easy Peasy' achievement.",
                delay: 259200
            )
        }

        // Nutrition reminder after 5 days
        if pantryCount > 0 {
            scheduleLocalNotification(
                title: "Check your nutrition! 🥗",
                body: "View your nutrition insights to stay on track with your health goals.",
                delay: 432000
            )
        }
    }

    func scheduleRecipeReminder(recipeName: String, delay: TimeInterval = 3600) {
        guard isAuthorized else { return }

        scheduleLocalNotification(
            title: "Ready to cook? 🍽️",
            body: "Try \(recipeName) - you have all the ingredients in your pantry!",
            delay: delay
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with userInfo: \(userInfo)")
        let details = userInfo as? [String: Any] ?? [:]
        AnalyticsHelper.trackFeatureUsed("notification_tapped", details: details)
        completionHandler()
    }
}
