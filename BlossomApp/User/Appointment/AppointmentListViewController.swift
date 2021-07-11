//
//  AppointmentListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit

class AppointmentListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ตารางนัดหมาย"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gotoOrderList()
    }
    
    func gotoOrderList() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deeplinking = appDelegate.deeplinking {
            switch deeplinking {
            case .orderList:
                debugPrint("go to order list")
            }            
            appDelegate.deeplinking = nil
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
