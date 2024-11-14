//
//  NotificationManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/10.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func postNetworkChangeNotification() {
        NotificationCenter.default.post(
            name: Notification.Name("NetworkingReachabilityDidChange"),
            object: nil
        )
    }
    
    func scheduleLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
