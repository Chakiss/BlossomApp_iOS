//
//  AppDelegate.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 2/7/2564 BE.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        FirebaseApp.configure()
       
        configUI()
       
        
        let user = Auth.auth().currentUser
        
        if (user != nil) {

        } else {
            Auth.auth().signInAnonymously { authResult, error in
               
            }
        }
        return true
        
    }
    
    private func configUI() {
        let tabBarItemAppearance = UITabBarItem.appearance()
        let tabAttributes = [NSAttributedString.Key.font:UIFont(name: "SukhumvitSet-SemiBold", size: 10)]
        tabBarItemAppearance.setTitleTextAttributes(tabAttributes as [NSAttributedString.Key : Any], for: .normal)
        
        let navAttributes = [NSAttributedString.Key.font: UIFont(name: "SukhumvitSet-Bold", size: 16),
                             NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = navAttributes as [NSAttributedString.Key : Any]
        UINavigationBar.appearance().barTintColor = UIColor.blossomPrimary3

        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
        
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


}

