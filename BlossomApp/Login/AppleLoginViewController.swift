//
//  AppleLoginViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 10/8/2564 BE.
//

import UIKit
import Firebase
import AuthenticationServices
import SwiftyUserDefaults

class AppleLoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {

    fileprivate var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
   
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

}

extension AppleLoginViewController: ASAuthorizationControllerDelegate {
    
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
