//
//  RegisterViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 11/7/2564 BE.
//

import UIKit
import DLRadioButton
import FirebaseFunctions


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
      
        if passwordTextField.text != confirmPasswordTextField.text {
            let alert = UIAlertController(title: "Alert", message: "กรุณาตรวจสอบพาสเวิร์ดอีกครั้ง", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            ProgressHUD.show()
            
            let payload = ["email": emailTextField.text,
                           "password": passwordTextField.text,
                           "firstName": nameTextField.text,
                           "lastName": sueNameTextField.text,
                           "phoneNumber": phoneNumberTextField.text]
            
            functions.httpsCallable("app-users-signUpWithEmailAndPassword").call(payload) { result, error in
                ProgressHUD.dismiss()
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        
                        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    // ...
                }
                if let data = result?.data as? [String: Any], let text = data["text"] as? String {
                    //self.resultField.text = text
                    print(data)
                }
            }
            
        }
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
