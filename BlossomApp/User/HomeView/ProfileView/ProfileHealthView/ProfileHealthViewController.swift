//
//  ProfileHealthViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase
import FBSDKLoginKit
import AuthenticationServices


class ProfileHealthViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var acneTypeView: UIView!
    @IBOutlet weak var acneType: DLRadioButton!
    var acneTypeString: String = ""
    
    @IBOutlet weak var skinTypeView: UIView!
    @IBOutlet weak var skinTypeButton: DLRadioButton!
    var skinTypeString: String = ""
    
    @IBOutlet weak var allergicDrugView: UIView!
    @IBOutlet weak var allergicDrugType: DLRadioButton!
    @IBOutlet weak var allergicDrugTextField: UITextField!
    var allergicDrugString: String = ""
    
    @IBOutlet weak var acneCaredDescriptionView: UIView!
    @IBOutlet weak var acneCaredType: DLRadioButton!
    @IBOutlet weak var acneCaredTextField: UITextField!
    var acneCaredString: String = ""
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    var customer:Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        displayInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        informationView.addConerRadiusAndShadow()
        
        
    }
    
    func displayInformation() {
        
        self.skinTypeString = self.customer?.skinType ?? ""
        if self.customer?.skinType == "ผิวแห้ง"  {
            skinTypeButton.isSelected = true
        } else if  self.customer?.skinType == "ผิวมันทั่วหน้า" {
            skinTypeButton.otherButtons[0].isSelected = true
        } else if self.customer?.skinType == "ผิวมันผสม, มันเฉพาะ T zone"{
            skinTypeButton.otherButtons[1].isSelected = true
        } else if self.customer?.skinType == "ผิวแพ้ง่าย" {
            skinTypeButton.otherButtons[2].isSelected = true
        }
        
      
        self.acneTypeString = self.customer?.acneType ?? ""
        if self.customer?.acneType == "สิวอุดตัน"  {
            acneType.isSelected = true
        } else if  self.customer?.acneType == "สิวอักเสบ" {
            acneType.otherButtons[0].isSelected = true
        } else if self.customer?.acneType == "สิวอักเสบ สัมพันธ์กับรอบเดือน" {
            acneType.otherButtons[1].isSelected = true
        } else if self.customer?.acneType == "รอยสิว" {
            acneType.otherButtons[2].isSelected = true
        } else if self.customer?.acneType == "หลุมสิว" {
            acneType.otherButtons[3].isSelected = true
        }
        
        
        self.allergicDrugString = self.customer?.allergicDrug ?? ""
        if self.allergicDrugString.count > 0 {
            allergicDrugType.isSelected = true
            self.allergicDrugTextField.text = self.allergicDrugString
        } else {
            allergicDrugType.otherButtons[0].isSelected = true
        }
        
        
        self.acneCaredString = self.customer?.acneCaredDescription ?? ""
        if self.acneCaredString.count > 0 {
            acneCaredType.isSelected = true
            self.acneCaredTextField.text = self.acneCaredString
        } else {
            acneCaredType.otherButtons[0].isSelected = true
        }
 
    }
    
    @objc @IBAction private func skinTypeSelectedButton(radioButton : DLRadioButton) {
        
        if radioButton.tag == 1 {
            self.skinTypeString = "ผิวแห้ง"
        } else if radioButton.tag == 2 {
            self.skinTypeString = "ผิวมันทั่วหน้า"
        } else if radioButton.tag == 3 {
            self.skinTypeString = "ผิวมันผสม, มันเฉพาะ T zone"
        } else {
            self.skinTypeString = "ผิวแพ้ง่าย"
        }
        
        NotificationCenter.default.post(name: Notification.Name("BlossomHealthChanged"), object: nil)
        
    }
    
    @objc @IBAction private func acneTypeSelectedButton(radioButton : DLRadioButton) {
        
        if radioButton.tag == 1 {
            self.acneTypeString = "สิวอุดตัน"
        } else if radioButton.tag == 2 {
            self.acneTypeString = "สิวอักเสบ"
        } else if radioButton.tag == 3 {
            self.acneTypeString = "สิวอักเสบ สัมพันธ์กับรอบเดือน"
        } else if radioButton.tag == 3 {
            self.acneTypeString = "รอยสิว"
        } else if radioButton.tag == 4 {
            self.acneTypeString = "หลุมสิว"
        }
        
        NotificationCenter.default.post(name: Notification.Name("BlossomHealthChanged"), object: nil)
        
    }

 
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == allergicDrugTextField {
            if textField.text != customer?.allergicDrug {
                NotificationCenter.default.post(name: Notification.Name("BlossomProfileChanged"), object: nil)
            }
        }
        else if textField == acneCaredTextField {
            if textField.text != customer?.acneCaredDescription {
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
}
