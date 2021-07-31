//
//  ProfileInformationViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit
import ConnectyCube

class ProfileInformationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    
    @IBOutlet weak var birthDayTextField: UITextField!
    let datePicker = UIDatePicker()

    var showLogout: Bool = true
    
    @IBOutlet weak var addressTextField: UITextView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var phoneVerifyButton: UIButton!
    //@IBOutlet weak var emailVerifyButton: UIButton!
    
    @IBOutlet weak var gendorView: UIView!
    @IBOutlet weak var manButton: DLRadioButton!
    
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var facebookNameLabel: UILabel!
    @IBOutlet weak var connectAppleButton: UIButton!
    @IBOutlet weak var appleNameLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    

    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    var customer:Customer?
    
    
    var isLinkFacebook: Bool = false
    var isLinkApple: Bool = false
    
    fileprivate var currentNonce: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signOutButton.isHidden = !showLogout
        birthDayTextField.addInputViewDatePicker(target: self, selector: #selector(doneButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        informationView.addConerRadiusAndShadow()
        nameTextField.addBottomBorder()
        surNameTextField.addBottomBorder()
        birthDayTextField.addBottomBorder()
        addressTextField.addBottomBorder()
        
        
        phoneVerifyButton.layer.cornerRadius = 15
       // emailVerifyButton.layer.cornerRadius = 15
        connectFacebookButton.layer.cornerRadius = 15
        connectAppleButton.layer.cornerRadius = 15
        signOutButton.layer.cornerRadius = 22
        
        
        
        
    }
    
    func displayInformation(){
        
        self.nameTextField.text = self.customer?.firstName
        self.surNameTextField.text = self.customer?.lastName
        
        if self.customer?.phoneNumber?.count ?? 0 > 0 {
            self.phoneTextField.text = self.customer?.phoneNumber?.phonenumberformat()
        }
        self.emailTextField.text = self.customer?.email
        
        if self.customer?.isPhoneVerified == true {
            self.phoneVerifyButton.setTitle("ยืนยันแล้ว ต้องการเปลี่ยนเบอร์", for: .normal)
            self.phoneVerifyButton.addTarget(self, action: #selector(self.changePhoneNumberButtonTapped), for: .touchUpInside)
        } else {
            self.phoneVerifyButton.setTitle("ยังไม่ได้ยืนยัน", for: .normal)
            self.phoneVerifyButton.addTarget(self, action: #selector(self.phoneNumberVerifyButtonTapped), for: .touchUpInside)
        }
        
        
        if self.customer?.gender == "male" {
            manButton.isSelected = true
        } else if self.customer?.gender == "female" {
            manButton.otherButtons[0].isSelected = true
        } else {
            manButton.otherButtons[1].isSelected = true
        }
        
        
        self.birthDayTextField.text = customer?.birthDayDisplayString
        
        self.addressTextField.text = customer?.address?.address
        
        
        let userInfoList: [UserInfo] = user?.providerData ?? []
        for userInfo in userInfoList {
            print(userInfo.providerID)
            if userInfo.providerID.contains("facebook") {
                isLinkFacebook = true
            } else if userInfo.providerID.contains("apple") {
                isLinkApple = true
            }
        }
        
        checkLinkAccount()
            
    }
    
    @IBAction func phoneNumberVerifyButtonTapped() {
        
        let phoneNumber = self.customer?.phoneNumber
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verificationID, error in
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "VerifyPhoneNumberViewController") as! VerifyPhoneNumberViewController
                    viewController.verificationID = verificationID!
                    viewController.phoneNumber = phoneNumber!
                    self.navigationController?.present(viewController, animated: true, completion: nil)
                }
                
            }
        
    }
    
    @IBAction func changePhoneNumberButtonTapped() {
        //app-users-updatePhoneNumber
        ProgressHUD.show()
        
        var phoneNumber = ""
        if phoneTextField.text?.count == 10 {
            if phoneTextField.text?.first == "0" {
                phoneNumber = phoneTextField.text?.addCountryCode() ?? ""
                let payload = ["phoneNumber": phoneNumber]
                
                functions.httpsCallable("app-users-updatePhoneNumber").call(payload) { result, error in
                    ProgressHUD.dismiss()
                    if error != nil {
                        let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        
                    }
                }
            }
        }
        
    }
    
    
    func checkLinkAccount(){
        if isLinkFacebook {
            self.connectFacebookButton.setTitle("Unlink", for: .normal)
            self.connectFacebookButton.addTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
            if let accessToken  = AccessToken.current {
                let r = GraphRequest(graphPath: "me",
                                          parameters: ["fields": "email,name"],
                                          tokenString: AccessToken.current!.tokenString,
                                          version: nil,
                                          httpMethod: HTTPMethod.get)

                r.start { test, result, error in
                    if error == nil {
                        guard let json = result as? NSDictionary else { return }
                        self.facebookNameLabel.text = json["name"] as? String ?? ""
                    }
                }
            } else {

                let userInfoList: [UserInfo] = self.user?.providerData ?? []
                for userInfo in userInfoList {
                    if userInfo.providerID.contains("facebook") {
                        Auth.auth().currentUser?.unlink(fromProvider: userInfo.providerID) { user, error in
                            ProgressHUD.dismiss()
                            self.isLinkFacebook = false
                            self.connectFacebookButton.removeTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
                            self.displayInformation()
                        }
                    }
                }
            }
           
        } else {
            self.facebookNameLabel.text = ""
            self.connectFacebookButton.setTitle("Link", for: .normal)
            self.connectFacebookButton.addTarget(self, action: #selector(self.linkAccountFacebook), for: .touchUpInside)

        }
        
        if isLinkApple {
            self.appleNameLabel.text = "เชื่อมต่อแล้ว"
            self.connectAppleButton.setTitle("Unlink", for: .normal)
            self.connectAppleButton.addTarget(self, action: #selector(self.unLinkAccountApple), for: .touchUpInside)
        } else {
            self.appleNameLabel.text = ""
            self.connectAppleButton.setTitle("Link", for: .normal)
            self.connectAppleButton.addTarget(self, action: #selector(self.linkAccountApple), for: .touchUpInside)
        }
    }
    
    
    @objc func linkAccountFacebook(){
       
        ProgressHUD.show()
        
        LoginManager.init().logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { (loginResult) in
          switch loginResult {
          case .success:
            let credential = FacebookAuthProvider
                .credential(withAccessToken: AccessToken.current!.tokenString)
            self.user?.link(with: credential) { authResult, error in
                ProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.isLinkFacebook = true
                    self.connectFacebookButton.removeTarget(self, action: #selector(self.linkAccountFacebook), for: .touchUpInside)
                    self.displayInformation()
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
    
    @objc func unLinkAccountFacebook() {
        let alert = UIAlertController(title: "โปรไฟล์มีการแก้ไข", message: "คุณค้องการยกเลิกการเชื่อมต่อบัญชีกับ facebook หรือไม่​ ?",         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "ตกลง", style: .destructive, handler: {(_: UIAlertAction!) in
            ProgressHUD.show()
            let userInfoList: [UserInfo] = self.user?.providerData ?? []
            for userInfo in userInfoList {
                if userInfo.providerID.contains("facebook") {
                    Auth.auth().currentUser?.unlink(fromProvider: userInfo.providerID) { user, error in
                        ProgressHUD.dismiss()
                        self.isLinkFacebook = false
                        self.connectFacebookButton.removeTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
                        self.displayInformation()
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func linkAccountApple(){
        
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
    
    @objc func unLinkAccountApple(){
        let alert = UIAlertController(title: "โปรไฟล์มีการแก้ไข", message: "คุณค้องการยกเลิกการเชื่อมต่อบัญชีกับ Apple หรือไม่​ ?",         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "ตกลง", style: .destructive, handler: {(_: UIAlertAction!) in
            ProgressHUD.show()
            let userInfoList: [UserInfo] = self.user?.providerData ?? []
            for userInfo in userInfoList {
                if userInfo.providerID.contains("apple") {
                    // Clear saved user ID
                    Auth.auth().currentUser?.unlink(fromProvider: userInfo.providerID) { user, error in
                        ProgressHUD.dismiss()
                        UserDefaults.standard.set(nil, forKey: "appleAuthorizedUserIdKey")
                        self.isLinkApple = false
                        self.connectAppleButton.removeTarget(self, action: #selector(self.unLinkAccountApple), for: .touchUpInside)
                        self.displayInformation()// ...
                    }
                    
                }
                
              
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
            // Perform sign out from Firebase
            
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    
    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        
        if radioButton.tag == 1 {
            self.customer?.genderString = "male"
        } else if radioButton.tag == 2 {
            self.customer?.genderString = "female"
        } else {
            self.customer?.genderString = ""
        }
        NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
        
    }
    
    
    @IBAction func logoutButtonTapped() {
        let alert = UIAlertController(title: "ออกจากระบบ ?", message: "คุณค้องการออกจากระบบหรือไม่​ ?",         preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: {(_: UIAlertAction!) in
            //Sign out action
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                CustomerManager.sharedInstance.logout()
                
                Chat.instance.disconnect { (error) in

                }
                
                Request.logOut(successBlock: {
                    print("xxxx")
                }) { (error) in
                    print(error)
                }
                UIApplication.shared.unregisterForRemoteNotifications()

                // Unregister from server
                let deviceIdentifier = UIDevice.current.identifierForVendor!.uuidString
                Request.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: {

                }) { (error) in

                }
                
                
                self.navigationController?.popToRootViewController(animated: true)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                
                let regsterNavigationController = UINavigationController(rootViewController: viewController)
                regsterNavigationController.modalPresentationStyle = .fullScreen
                regsterNavigationController.navigationBar.tintColor = UIColor.white
                self.navigationController?.present(regsterNavigationController, animated: true, completion:nil)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            if textField.text != customer?.firstName {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        else if textField == surNameTextField {
            if textField.text != customer?.lastName {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        else if textField == addressTextField {
            if textField.text != customer?.lastName {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        else if textField == birthDayTextField {
            if textField.text != customer?.birthDayString {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        else if textField == phoneTextField {
            if textField.text != customer?.phoneNumber {
                NotificationCenter.default.post(name: Notification.Name("BlossomPhoneNumberChanged"), object: nil)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == addressTextField {
            if textView.text != customer?.address?.address {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
    }
    
    // hides text views
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    // hides text fields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func doneButtonPressed() {
        if let  datePicker = self.birthDayTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            customer?.birthDayString = dateFormatter.string(from: datePicker.date)
            dateFormatter.dateStyle = .medium
            self.birthDayTextField.text = dateFormatter.string(from: datePicker.date)
        }
        self.birthDayTextField.resignFirstResponder()
     }
    
}


extension ProfileInformationViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
            
            self.user?.link(with: firebaseCredential) { authResult, error in
                ProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.isLinkApple = true
                    self.connectAppleButton.removeTarget(self, action: #selector(self.linkAccountApple), for: .touchUpInside)
                    self.displayInformation()
                }
            }
      
        }
        
        
    }


  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}


extension UITextView {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.blossomLightGray.cgColor
        layer.addSublayer(bottomLine)
    }
}
extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.blossomLightGray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
    
    func addInputViewDatePicker(target: Any, selector: Selector) {
        
        let screenWidth = UIScreen.main.bounds.width
        
        //Add DatePicker as inputView
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
        
        }
        datePicker.datePickerMode = .date
        self.inputView = datePicker
        
        //Add Tool Bar as input AccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: false)
        
        self.inputAccessoryView = toolBar
    }
    
    @objc func cancelPressed() {
        self.resignFirstResponder()
    }
    
}
