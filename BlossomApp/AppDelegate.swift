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

enum Deeplinking {
    case orderList
    case appointment
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var deeplinking: Deeplinking?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
       
        Settings.applicationID = 4655
        Settings.authKey = "88p8mWQ9NMcx4SL"
        Settings.authSecret = "XPnwQ5uR5FFJAXj"
        Settings.accountKey = "sdfhdfy2329763buiyi"
        Settings.autoReconnectEnabled = true
        
        configUI()
        CommonKeyboard.shared.enabled = true
       
        return true
        
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
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
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

