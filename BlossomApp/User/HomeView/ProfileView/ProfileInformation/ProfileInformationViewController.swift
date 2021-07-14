//
//  ProfileInformationViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase

class ProfileInformationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    
    @IBOutlet weak var birthDayTextField: UITextField!
    let datePicker = UIDatePicker()
    var birthDayString: String = ""
    var birthDayDisplayString: String = ""
    
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var phoneVerifyButton: UIButton!
    @IBOutlet weak var emailVerifyButton: UIButton!
    
    @IBOutlet weak var gendorView: UIView!
    @IBOutlet weak var manButton: DLRadioButton!
    var genderString:String = ""
    
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var connectAppleButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    var customer:Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        emailVerifyButton.layer.cornerRadius = 15
        connectFacebookButton.layer.cornerRadius = 15
        connectAppleButton.layer.cornerRadius = 15
        signOutButton.layer.cornerRadius = 22
        
        //NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
        
        db.collection("customers").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            self.customer = snapshot?.data().map({ documentData -> Customer in
                let id = snapshot?.documentID ?? ""
                let createdAt = documentData["createdAt"] as? String ?? ""
                let displayName = documentData["displayName"] as? String ?? ""
                let email = documentData["email"] as? String ?? ""
                let firstName = documentData["firstName"] as? String ?? ""
                let isEmailVerified: Bool = (documentData["isEmailVerified"] ?? false) as! Bool
                let isPhoneVerified: Bool = (documentData["isPhoneVerified"] ?? false) as! Bool
                let lastName = documentData["lastName"] as? String ?? ""
                let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                let platform = documentData["platform"] as? String ?? ""
                let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? String ?? ""
                let referenceShipnityID = documentData["referenceShipnityID"] as? String ?? ""
                let updatedAt = documentData["updatedAt"] as? String ?? ""
                let gender = documentData["gender"] as? String ?? ""
                let birthDateTimestamp = documentData["birthDate"] as? Timestamp
                var birthDay = ""
                if let birthDate = birthDateTimestamp?.dateValue() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    birthDay = dateFormatter.string(from: birthDate)
                    dateFormatter.dateStyle = .medium
                    self.birthDayDisplayString = dateFormatter.string(from: birthDate)
                }
                
                let addressDic =  documentData["address"] as? [String: String] ?? [:]
                let address = addressDic["address"] ?? ""
        
                self.genderString = gender
                
                return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt, gender: gender, birthDate: birthDay)
            })
            
            self.displayInformation()
        }
        
        
        
    }
    
    func displayInformation(){
        
        self.nameTextField.text = self.customer?.firstName
        self.surNameTextField.text = self.customer?.lastName
        
        self.phoneTextField.text = self.customer?.phoneNumber
        self.emailTextField.text = self.customer?.email
        
        if self.customer?.isPhoneVerified == true {
            self.phoneVerifyButton.setTitle("ยืนยันแล้ว", for: .normal)
            self.phoneVerifyButton.isEnabled = false
        } else {
            self.phoneVerifyButton.setTitle("ยังไม่ได้ยืนยัน", for: .normal)
            self.phoneVerifyButton.isEnabled = false
        }
        
        if self.customer?.isEmailVerified == true {
            self.emailVerifyButton.setTitle("ยืนยันแล้ว", for: .normal)
            self.emailVerifyButton.isEnabled = false
        } else {
            self.emailVerifyButton.setTitle("ยังไม่ได้ยืนยัน", for: .normal)
            self.emailVerifyButton.isEnabled = false
        }
        
        if self.genderString == "male" {
            manButton.isSelected = true
        } else if self.genderString == "female" {
            manButton.otherButtons[0].isSelected = true
        } else {
            manButton.otherButtons[1].isSelected = true
        }
        
        
        self.birthDayTextField.text = birthDayDisplayString
        
        
    }

    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        
        if radioButton.tag == 1 {
            self.genderString = "male"
        } else if radioButton.tag == 2 {
            self.genderString = "female"
        } else {
            self.genderString = ""
        }
        NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
        print(self.genderString)
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
        } else if textField == birthDayTextField {
            if textField.text != birthDayString {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
  
    @objc func doneButtonPressed() {
        if let  datePicker = self.birthDayTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            birthDayString = dateFormatter.string(from: datePicker.date)
            dateFormatter.dateStyle = .medium
            self.birthDayTextField.text = dateFormatter.string(from: datePicker.date)
        }
        self.birthDayTextField.resignFirstResponder()
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
        datePicker.preferredDatePickerStyle = .wheels
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
