//
//  RegisterViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/7/2564 BE.
//

import UIKit
import DLRadioButton
import FirebaseFunctions
import Firebase

class RegisterViewController: UIViewController {

    lazy var functions = Functions.functions()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sueNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var acceptButton: DLRadioButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ลงทะเบียน"
        
        
        self.registerButton.layer.cornerRadius = 22
       
        self.acceptButton.isSelected = false
        self.registerButton.isEnabled = false
        self.registerButton.backgroundColor = .blossomLightGray
        
        let navAttributes = [NSAttributedString.Key.font: UIFont(name: "SukhumvitSet-Bold", size: 16),
                             NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = navAttributes as [NSAttributedString.Key : Any]
        UINavigationBar.appearance().barTintColor = UIColor.blossomPrimary3
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func acceptButtonTapped() {
        
        self.registerButton.isEnabled = true
        self.registerButton.backgroundColor = .blossomPrimary2
        
    }
    
    @IBAction func policyButtonTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        viewController.urlString = "https://www.blossomclinicthailand.com/policy/"
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func registerButtonTapped() {

        if phoneNumberTextField.text!.count > 0 {
            if phoneNumberTextField.text?.first != "0" || phoneNumberTextField.text!.count != 10 {
                let alert = UIAlertController(title: "แจ้งเตือน", message: "กรุณาแก้ไขเบอร์โทรศัพท์ให้ถูกต้อง", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            let alert = UIAlertController(title: "แจ้งเตือน", message: "กรุณาตรวจสอบพาสเวิร์ดอีกครั้ง", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            ProgressHUD.show()
            var phoneNumber = phoneNumberTextField.text
            if phoneNumber?.count == 10 {
                if phoneNumber?.first == "0" {
                    phoneNumber = phoneNumberTextField.text?.addCountryCode()
                }
            }
            let payload = ["email": emailTextField.text,
                           "password": passwordTextField.text,
                           "firstName": nameTextField.text,
                           "lastName": sueNameTextField.text,
                           "phoneNumber": phoneNumber]
            
            functions.httpsCallable("app-users-signUpWithEmailAndPassword").call(payload) { result, error in
                ProgressHUD.dismiss()
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        
                        let alert = UIAlertController(title: "Alert \(String(describing: code))", message: message, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    // ...
                }
                if let data = result?.data as? [String: Any]{
                    //self.resultField.text = text
                    
                    if let email = data["email"] as? String , let password = data["password"] as? String {
                        Auth.auth().signIn(withEmail: email , password: password ) { authResult, error in
                            
                            CustomerManager.sharedInstance.getCustomer {}
                            ProgressHUD.dismiss()
                            
                            authResult?.user.getIDTokenResult(completion: { (result, error) in
                                
                                let alert = UIAlertController(title: "สำเร็จ ", message: "ลงทะเบียนสำเร็จ ระบบกำลังนำคุณเข้าสู่ระบบ", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                                guard let role = result?.claims["role"] as? String else {
                                    // Show regular user UI.
                                    //showRegularUI()
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
                    
                }
            }
            
        }
    }
    
    
    
    
}
