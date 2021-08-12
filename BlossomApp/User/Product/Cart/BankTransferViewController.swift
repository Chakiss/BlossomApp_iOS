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
    
    
    @IBAction func copySCBButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string =  "2082364723"
        showAlertDialogue(title: "คัดลอกสำเร็จ", message: "2082364723") {}
    }
    
    @IBAction func copyKbankButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string =  "0408729920"
        
        showAlertDialogue(title: "คัดลอกสำเร็จ", message: "0408729920") {}
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