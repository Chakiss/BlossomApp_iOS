//
//  ProfileInformationViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton

class ProfileInformationViewController: UIViewController {

    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var gendorView: UIView!
    @IBOutlet weak var manButton: DLRadioButton!
    
    
    
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
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width - 40, height: 1)
        bottomLine.backgroundColor = UIColor.blossomLightGray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
