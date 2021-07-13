//
//  ProfileInformationViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase

class ProfileInformationViewController: UIViewController {

    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var phoneVerifyButton: UIButton!
    @IBOutlet weak var emailVerifyButton: UIButton!
    
    @IBOutlet weak var gendorView: UIView!
    @IBOutlet weak var manButton: DLRadioButton!
    
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    var customer:Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        informationView.addConerRadiusAndShadow()
        
        nameTextField.addBottomBorder()
        surNameTextField.addBottomBorder()
        birthDayTextField.addBottomBorder()
        addressTextField.addBottomBorder()
        emailTextField.addBottomBorder()
        phoneTextField.addBottomBorder()
        
        
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

                return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt)
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
        
        
    }

    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        
        print(String(format: "%@ is selected.\n", radioButton.selected()!.titleLabel!.text!));
        
        
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


extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.blossomLightGray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
