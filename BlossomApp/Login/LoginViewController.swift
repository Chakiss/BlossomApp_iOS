//
//  LoginViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/7/2564 BE.
//

import UIKit
import Firebase
import FBSDKLoginKit
import AuthenticationServices

class LoginViewController: UIViewController {
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ลงทะเบียน"

        self.loginButton.layer.cornerRadius = 22
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonTapped() {
        ProgressHUD.show()
    
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { authResult, error in
            ProgressHUD.dismiss()
            if error != nil {
                let alert = UIAlertController(title: "ข้อมูลของคุณไม่ถูกต้อง", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            authResult?.user.getIDTokenResult(completion: { (result, error) in
                
                guard let role = result?.claims["role"] as? String else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    return
                }
                if role == "doctor" {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                       appDelegate.setDoctorUI()
                    }
                } else {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                       appDelegate.setCustomerUI()
                    }
                }
            })
       
        }
        
    }
    
    @IBAction func facebookButtonTapped() {
        ProgressHUD.show()
        LoginManager.init().logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { (loginResult) in
          switch loginResult {
          case .success:
            let credential = FacebookAuthProvider
                .credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                ProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    authResult?.user.getIDTokenResult(completion: { (result, error) in
                        
                        guard let role = result?.claims["role"] as? String else {
                            self.navigationController?.dismiss(animated: true, completion: nil)
                            return
                        }
                        if role == "doctor" {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                               appDelegate.setDoctorUI()
                            }
                        } else {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                               appDelegate.setCustomerUI()
                            }
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
    
    @IBAction func appleButtonTapped() {
        
    }
    
    @IBAction func forgotButtonTapped() {
        
    }
    

}
