//
//  VerifyPhoneNumberViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 24/7/2564 BE.
//

import UIKit
import Firebase

class VerifyPhoneNumberViewController: UIViewController {

    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
        
    var phoneNumber: String = ""
    var verificationID: String = ""
    
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        verifyButton.layer.cornerRadius = 22
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func verifyButtonTapped(){
        //app-users-markPhoneNumberVerified
        ProgressHUD.show()
        let payload = ["phoneNumber": self.phoneNumber]
        
        functions.httpsCallable("app-users-markPhoneNumberVerified").call(payload) { result, error in
            Auth.auth().currentUser?.reload()
            ProgressHUD.dismiss()
            self.dismiss(animated: true, completion: nil)
            
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
