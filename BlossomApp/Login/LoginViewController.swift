//
//  LoginViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/7/2564 BE.
//

import UIKit
import Firebase

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
                       appDelegate.setDoctorUI()
                    }
                }
            })
       
        }
        
    }
    
    @IBAction func facebookButtonTapped() {
        
    }
    
    @IBAction func appleButtonTapped() {
        
    }
    
    @IBAction func forgotButtonTapped() {
        
    }
    

}
