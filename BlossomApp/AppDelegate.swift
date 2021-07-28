//
//  AppDelegate.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 2/7/2564 BE.
//

import UIKit
import Firebase
import FBSDKCoreKit
import CommonKeyboard
import PushKit
import UserNotifications
import SwiftyUserDefaults

enum Deeplinking {
    case orderList
    case appointment
    case chat
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
   
    var deeplinking: Deeplinking?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        application.applicationIconBadgeNumber = 0
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound, .alert, .badge]) { [weak self] (granted, error) in
            // Enable or disable features based on authorization
            if granted {
                self?.getNotificationSettings()
            }
        }
        application.registerForRemoteNotifications()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
       
        Messaging.messaging().subscribe(toTopic: "general") { error in
          print("Subscribed to general topic")
        }
        Messaging.messaging().subscribe(toTopic: "announcement") { error in
          print("Subscribed to announcement topic")
        }
    
        configUI()
        CommonKeyboard.shared.enabled = true
            
        CallManager.manager.setupCallManager()
        
        return true
        
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }            
        }
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        let pushCredentials = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("didRegisterForRemoteNotificationsWithDeviceToken -> deviceToken :\(pushCredentials)")
        CustomerManager.sharedInstance.saveDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("userInfo")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        print("userInfo")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
     }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("userNotificationCenter")
    }
    
    func handleDeeplinking() {
        
        guard let tabbarController = window?.rootViewController as? UITabBarController,
              let deeplinking = deeplinking else {
            return
        }
        if Defaults[\.role] == "doctor"{
            switch deeplinking {
            case .orderList:
                tabbarController.selectedIndex = 1
            case .appointment:
                tabbarController.selectedIndex = 1
            case .chat:
                tabbarController.selectedIndex = 2
            }
        } else {
            switch deeplinking {
            case .orderList:
                tabbarController.selectedIndex = 2
            case .appointment:
                tabbarController.selectedIndex = 2
            case .chat:
                tabbarController.selectedIndex = 4
            }
        }
        
        
        
    }
    
    private func configUI() {
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        let tabAttributes = [NSAttributedString.Key.font:UIFont(name: "SukhumvitSet-SemiBold", size: 10)]
        tabBarItemAppearance.setTitleTextAttributes(tabAttributes as [NSAttributedString.Key : Any], for: .normal)
        
        let navAttributes = [NSAttributedString.Key.font: UIFont(name: "SukhumvitSet-Bold", size: 16),
                             NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = navAttributes as [NSAttributedString.Key : Any]
        UINavigationBar.appearance().barTintColor = UIColor.blossomPrimary3
        
    }
    
    // MARK: -
    
    func setCustomerUI(){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let customerTabbar = mainStoryboard.instantiateViewController(withIdentifier: "CustomerTabbar")
        self.window!.rootViewController = customerTabbar
        
    }

    func setDoctorUI(){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Doctor", bundle: nil)
        let customerTabbar = mainStoryboard.instantiateViewController(withIdentifier: "DoctorTabbar")
        self.window!.rootViewController = customerTabbar
                
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        //Chat.instance.disconnect { (error) in
       // }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //Chat.instance.disconnect { (error) in
        //}
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
         
    }
}

