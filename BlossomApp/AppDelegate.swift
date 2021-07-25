//
//  AppDelegate.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 2/7/2564 BE.
//

import UIKit
import Firebase
import ConnectyCube
import ConnectyCubeCalls
import FBSDKCoreKit
import CommonKeyboard
import PushKit
import UserNotifications

enum Deeplinking {
    case orderList
    case appointment
    case chat
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {
   
    

    var deeplinking: Deeplinking?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        registerForPushNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
       
        Settings.applicationID = 4655
        Settings.authKey = "88p8mWQ9NMcx4SL"
        Settings.authSecret = "XPnwQ5uR5FFJAXj"
        Settings.accountKey = "sdfhdfy2329763buiyi"
        //Settings.autoReconnectEnabled = true
        
        configUI()
        CommonKeyboard.shared.enabled = true
        self.registerForPushNotifications()
        self.voipRegistration()
        
        
        
        //Messaging.messaging().delegate = self
        
        return true
        
    }
    
    func registerForPushNotifications() {
      //1
      UNUserNotificationCenter.current()
        //2
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          //3
          print("Permission granted: \(granted)")
        }
    }
    
    func voipRegistration() {
        
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
         // Create a push registry object
     }
    
    
    
    // Handle updated push credentials

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        print(pushCredentials.token)
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString

        let subscription: Subscription! = Subscription()
        subscription.notificationChannel = NotificationChannel.APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = pushCredentials.token

        Request.createSubscription(subscription, successBlock: { (subscriptions) in
            print(subscriptions)
        }) { (error) in
            print(error)
        }
    }
    
    // MARK: - PKPushRegistryDelegate protocol

       func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
           print("pushRegistry:didInvalidatePushTokenForType:")
       }
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("didReceiveIncomingPushWithPayload")
    }
    
    
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription: Subscription! = Subscription()
        
        subscription.notificationChannel = NotificationChannel.APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken

        Request.createSubscription(subscription, successBlock: { (subscriptions) in
            print(subscriptions)
        }) { (error) in
            print(error)
        }
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
    
    func handleDeeplinking() {
        
        guard let tabbarController = window?.rootViewController as? UITabBarController,
              let deeplinking = deeplinking else {
            return
        }
        
        switch deeplinking {
        case .orderList:
            tabbarController.selectedIndex = 2
        case .appointment:
            tabbarController.selectedIndex = 2
        case .chat:
            tabbarController.selectedIndex = 4
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
        Chat.instance.disconnect { (error) in
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Chat.instance.disconnect { (error) in
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }
}

