//
//  Notifications.swift
//  Todoey
//
//  Created by mladen on 17.12.20..
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications{
    let notificationCenter = UNUserNotificationCenter.current()
        
        func userRequest() {
            
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            
            notificationCenter.requestAuthorization(options: options) {
                (didAllow, error) in
                if !didAllow {
                    print("User has declined notifications")
                }
            }
        }
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent()
        
        
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType + "Notifications"
        content.sound = UNNotificationSound.default
        content.badge = 1
    }
}
