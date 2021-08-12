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

class LoginViewController: UIViewController {
   
    
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "เข้าสู่ระบบ"

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FacebookLoginViewController") as! FacebookLoginViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @IBAction func appleButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AppleLoginViewController") as! AppleLoginViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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
    
    
   
}



