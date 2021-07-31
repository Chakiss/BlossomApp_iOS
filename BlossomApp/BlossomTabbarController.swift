//
//  TabbarController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 31/7/2564 BE.
//

import UIKit
import SwiftyUserDefaults

class BlossomTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title == "ข้อความ" {
            item.badgeValue = nil
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
