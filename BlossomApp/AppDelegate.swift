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
import FirebaseRemoteConfig


protocol DeeplinkingHandler {
    var shouldHandleDeeplink: Bool { get set }
    func handleDeeplink()
}

enum Deeplinking {
    case home
    case orderList
    case appointment
    case appointmentHistory
    case chat(id:String?)
    case product(id:String?)
    case doctor
    
    static func convert(from url: URL?) -> Deeplinking {

        guard let url = url else {
            return Deeplinking.home
        }

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Deeplinking.home
        }
        
        guard urlComponents.scheme == "blossomapp" else {
            return Deeplinking.home
        }
        
        switch urlComponents.host {
        
        case "appointment":
            return Deeplinking.appointment

        case "appointmentHistory":
            return Deeplinking.appointmentHistory

        case "orderList":
            return Deeplinking.orderList

        case "chat":
            var id = ""
            if urlComponents.queryItems?.first?.name == "id" {
                id = urlComponents.queryItems?.first?.value ?? ""
            }
            return Deeplinking.chat(id: id)
            
        case "doctor":
            return Deeplinking.doctor

        case "product":
            var id = ""
            if urlComponents.queryItems?.first?.name == "id" {
                id = urlComponents.queryItems?.first?.value ?? ""
            }
            return Deeplinking.product(id: id)

        default:
            return Deeplinking.home
            
        }
        
    }
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
        
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 43200 // 12 * 60 * 60
        remoteConfig.configSettings = settings
        RemoteConfig.remoteConfig().fetch {  _, error in
            if let error = error {
                
                return
            }
            
            RemoteConfig.remoteConfig().activate { _, _ in
                
            }
        }
        
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
        
        let handled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return handled
        
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print(url)
        return true
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
        print("didReceiveRemoteNotification \(userInfo)")
        saveMessage(userInfo: userInfo)
        handlePush(userInfo: userInfo)
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        print("didReceiveRemoteNotification completionHandler \(userInfo)")
        saveMessage(userInfo: userInfo)
        handlePush(userInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        let userInfo = notification.request.content.userInfo
        print("\(userInfo)")
        saveMessage(from: notification.request.identifier, userInfo: userInfo)
        completionHandler(.alert)
     }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        let userInfo = response.notification.request.content.userInfo
        print("\(userInfo)")
        saveMessage(from: response.notification.request.identifier, userInfo: userInfo)
        handlePush(userInfo: userInfo)

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("userNotificationCenter")
    }
    
    private func saveMessage(from identifier: String? = nil, userInfo: [AnyHashable: Any]) {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            return
        }

        let alert = aps["alert"] as? [String: Any]
        let message = alert?["body"] as? String
        InboxMessage.addNewInbox(identifier: identifier, message: message, deeplink: aps["deeplink"] as? String)
    }
    
    private func handlePush(userInfo: [AnyHashable: Any]) {
        
        guard let aps = userInfo["aps"] as? [String: Any],
              let deeplinkURL = aps["deeplink"] as? String else {
            return
        }
        
        self.deeplinking = Deeplinking.convert(from: URL(string: deeplinkURL))
        handleDeeplinking()
        
    }
    
    func handleDeeplinking() {
        
        guard let tabbarController = window?.rootViewController as? UITabBarController,
              let deeplinking = deeplinking else {
            return
        }
        
        if Defaults[\.role] == "doctor"{
            switch deeplinking {
            case .appointment, .appointmentHistory, .orderList:
                tabbarController.selectedIndex = 1
            case .chat(let id):
                let nav = tabbarController.viewControllers?[2] as! UINavigationController
                let productVC = nav.viewControllers.first as! ChatListViewController
                productVC.deeplinkID = id ?? ""
                tabbarController.selectedIndex = 2
            case .product, .home, .doctor:
                break
            }
        } else {
            switch deeplinking {
            case .home:
                tabbarController.selectedIndex = 0
            case .doctor:
                tabbarController.selectedIndex = 1
            case .appointment, .appointmentHistory, .orderList:
                tabbarController.selectedIndex = 2
            case .product(let id):
                let nav = tabbarController.viewControllers?[3] as! UINavigationController
                let productVC = nav.viewControllers.first as! ProductListViewController
                productVC.deeplinkID = id ?? ""
                tabbarController.selectedIndex = 3
            case .chat(let id):
                let nav = tabbarController.viewControllers?[4] as! UINavigationController
                //let productVC = nav.viewControllers.first as! ChatListViewController
                //productVC.deeplinkID = id ?? ""
                tabbarController.selectedIndex = 4
            }
        }
        
        if let selectedViewController = tabbarController.selectedViewController as? UINavigationController,
           let handler = selectedViewController.viewControllers.first as? DeeplinkingHandler {
            handler.handleDeeplink()
        }
        
    }
    
    private func configUI() {
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        let tabAttributes = [NSAttributedString.Key.font:UIFont(name: "SukhumvitSet-SemiBold", size: 10)]
        tabBarItemAppearance.setTitleTextAttributes(tabAttributes as [NSAttributedString.Key : Any], for: .normal)
        
        let navAttributes = [NSAttributedString.Key.font: UIFont(name: "SukhumvitSet-Bold", size: 16),
                             NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes = navAttributes as [NSAttributedString.Key : Any]
        UINavigationBar.appearance().barTintColor = UIColor.blossomPrimary
        UINavigationBar.appearance().isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.blossomPrimary
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                              NSAttributedString.Key.font:UIFont(name: "SukhumvitSet-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16)]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
           
          
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.configureWithOpaqueBackground()
            tabbarAppearance.backgroundColor = UIColor.white
            
            UITabBar.appearance().standardAppearance = tabbarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabbarAppearance
            
            
        }
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

