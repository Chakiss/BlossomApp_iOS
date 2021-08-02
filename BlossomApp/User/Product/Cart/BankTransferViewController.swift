//
//  BankTransferViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 2/8/2564 BE.
//

import UIKit

class BankTransferViewController: UIViewController {

    static func initializeInstance() -> BankTransferViewController {
        let controller: BankTransferViewController = BankTransferViewController(nibName: "BankTransferViewController", bundle: Bundle.main)
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func lineButtonTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://lin.ee/iYHm3As")!, options: [:], completionHandler: nil)
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
