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
        
        ProgressHUD.show()
        let payload = ["token": verificationID,
                       "code": otpTextField.text ?? ""]
        
        functions.httpsCallable("app-users-verifyPhoneNumberOTP").call(payload) { result, error in
            ProgressHUD.dismiss()
            if error == nil {
                
                let payloadMarkPhoneNumberVerified = ["phoneNumber": self.phoneNumber]
                self.functions.httpsCallable("app-users-markPhoneNumberVerified").call(payloadMarkPhoneNumberVerified) { result, error in
                    Auth.auth().currentUser?.reload()
                    self.dismiss(animated: true, completion: nil)
                    
                }
            } else {
                let alert = UIAlertController(title: "เกิดข้อผิดพลาด", message: error?.localizedDescription,  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(_: UIAlertAction!) in}))
                self.present(alert, animated: true, completion: nil)
                       }
        }
//        let credential = PhoneAuthProvider.provider().credential(
//          withVerificationID: verificationID,
//            verificationCode: otpTextField.text ?? ""
//        )
//
//        Auth.auth().signIn(with: credential) { authResult, error in
//            ProgressHUD.dismiss()
//            if error == nil {
//
//                let payload = ["phoneNumber": self.phoneNumber]
//                self.functions.httpsCallable("app-users-markPhoneNumberVerified").call(payload) { result, error in
//                    Auth.auth().currentUser?.reload()
//                    self.dismiss(animated: true, completion: nil)
//
//                }
//            } else {
//                let alert = UIAlertController(title: "เกิดข้อผิดพลาด", message: error?.localizedDescription,  preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(_: UIAlertAction!) in}))
//                self.present(alert, animated: true, completion: nil)
//            }
//            // User is signed in
//            // ...
//        }
//
//
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
