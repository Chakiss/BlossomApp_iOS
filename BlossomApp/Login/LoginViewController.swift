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
import SwiftyUserDefaults

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
   
    
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ลงทะเบียน"

        self.loginButton.layer.cornerRadius = 22
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonTapped() {
        ProgressHUD.show()
    
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { authResult, error in
            
            CustomerManager.sharedInstance.getCustomer {}
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
                
                Messaging.messaging().subscribe(toTopic: authResult?.user.uid ?? "") { error in
                  print("Subscribed to general-customer topic")
                }
                
                if role == "doctor" {
                    Messaging.messaging().subscribe(toTopic: "general-doctor") { error in
                      print("Subscribed to general-doctor topic")
                    }
                    
                    Defaults[\.role] = "doctor"
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                       appDelegate.setDoctorUI()
                    }
                    
                } else {
                    Messaging.messaging().subscribe(toTopic: "general-customer") { error in
                      print("Subscribed to general-customer topic")
                    }
                    
                    Defaults[\.role] = "customer"
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                       appDelegate.setCustomerUI()
                    }
                }
                //ConnectyCubeManager().login()
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
    
    @IBAction func appleButtonTapped() {
        ProgressHUD.show()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        self.currentNonce = Nonce().randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = Nonce().sha256(currentNonce!)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func forgotButtonTapped() {
        let alertController = UIAlertController(title: "ลืมพาสเวิร์ด ?", message: "กรุณากรอก email ที่ใช้ในการลงทะเบียน", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "email"
        }
       
        let saveAction = UIAlertAction(title: "ยืนยัน", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            Auth.auth().sendPasswordReset(withEmail: firstTextField.text ?? "") { error in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "สำเร็จ", message: "ระบบได้จัดส่ง Email เพื่อทำการ Reset password ของท่านแล้ว", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                                            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}



extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        ProgressHUD.dismiss()
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Do something with the credential...
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
                
                authResult?.user.getIDTokenResult(completion: { [weak self] (result, error) in
                    
                    guard let role = result?.claims["role"] as? String else {
                        ProgressHUD.dismiss()
                        authResult?.user.delete(completion: { error in
                            let alert = UIAlertController(title: "ไม่สามารถเข้าสู่ระบบได้", message: "ไม่พบบัญชี หรือคุณยังไม่ได้ผูกบัญชีเข้ากับ Apple ID กรุณาลงทะเบียน", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                                self?.navigationController?.popViewController(animated: true)
                            }))
                            self?.present(alert, animated: true, completion: nil)
                            
                        })
                        return
                    }
                    
                    ProgressHUD.dismiss()

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
                    } else {
                        Messaging.messaging().subscribe(toTopic: "general-customer") { error in
                          print("Subscribed to general-customer topic")
                        }
                        Defaults[\.role] = "customer"
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                           appDelegate.setCustomerUI()
                        }
                    }
                    
                })
            }
      
        }
        
        
    }


  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    ProgressHUD.dismiss()
    print("Sign in with Apple errored: \(error)")
  }
    

}
