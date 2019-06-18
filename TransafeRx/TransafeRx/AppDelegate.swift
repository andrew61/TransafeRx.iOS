//
//  AppDelegate.swift
//  TransafeRx
//
//  Created by Tachl on 7/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import UIKit
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DropDown.startListeningToKeyboard()
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]{
            NotificationManager.sharedManager.remoteNotifications.add(remoteNotification)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ApiManager.sharedManager.getAppVersion { (appVersion, error) in
            if appVersion != nil{
                if !appVersion!.isCurrentVersion(){
                    NotificationManager.sharedManager.showVersionNotificationDialog(animated: true)
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map{ String(format: "%02.2hhx", $0)}.joined()
        KeychainManager.sharedManager.keychain["apns"] = token
        print("token: \(token)")
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("Registered Remote Notifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to Register Remote Notifications")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("Received Local Notification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received Remote Notification: \(userInfo)")
        NotificationManager.sharedManager.remoteNotifications.add(userInfo)
        if KeychainManager.sharedManager.getIsLoggedIn(){
            NotificationManager.sharedManager.processRemoteNotification(userInfo: userInfo)
        }
        print("Remote Notification Size: \(NotificationManager.sharedManager.remoteNotifications.count)")
    }
}

