//
//  LoginViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/7/2564 BE.
//

import UIKit
import FirebaseFunctions

class LoginViewController: UIViewController {
    
    lazy var functions = Functions.functions()

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
        
       
    }
    
    @IBAction func facebookButtonTapped() {
        
    }
    
    @IBAction func appleButtonTapped() {
        
    }
    
    @IBAction func forgotButtonTapped() {
        
    }
    

}
