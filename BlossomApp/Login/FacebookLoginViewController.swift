//
//  FacebookLoginViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/8/2564 BE.
//

import UIKit
import Firebase
import FBSDKLoginKit
import AuthenticationServices
import SwiftyUserDefaults


class FacebookLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func facebookButtonTapped() {
       
        ProgressHUD.show()
        LoginManager.init().logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { (loginResult) in
          switch loginResult {
          case .success:
            let credential = FacebookAuthProvider
                .credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                
                //CustomerManager.sharedInstance.getCustomer {}
                ProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    authResult?.user.getIDTokenResult(completion: { (result, error) in
                        
                        guard let role = result?.claims["role"] as? String else {
                            authResult?.user.delete(completion: { error in
                                let alert = UIAlertController(title: "ไม่พบข้อมูล", message: "กรุณาลงทะเบียนก่อน", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                            })
                            return
                        }
                        
                        Messaging.messaging().subscribe(toTopic: authResult?.user.uid ?? "") { error in
                          print("Subscribed to general-customer topic")
                        }
                        
                        if role == "doctor" {
                            Messaging.messaging().subscribe(toTopic: "general-doctor") { error in
                              print("Subscribed to general-customer topic")
                            }
                            Defaults[\.role] = "doctor"
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                                appDelegate.setDoctorUI()
                            }
                        } else if role == "customer" {
                            Messaging.messaging().subscribe(toTopic: "general-customer") { error in
                              print("Subscribed to general-customer topic")
                            }
                            Defaults[\.role] = "customer"
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                                appDelegate.setCustomerUI()
                            }
                        } else {
                            print(role)
                        }

                    })
                    
                }
            }
            
          case .cancelled:
            ProgressHUD.dismiss()
              print("Login: cancelled.")
          case .failed(let error):
            ProgressHUD.dismiss()
            print("Login with error: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }
        }
    }
    

  
}
