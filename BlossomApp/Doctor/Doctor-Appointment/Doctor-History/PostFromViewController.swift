//
//  PostFromViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 28/7/2564 BE.
//

import UIKit
import Firebase

class PostFromViewController: UIViewController {

    @IBOutlet weak var diagnoseTextField: UITextField!
    @IBOutlet weak var carePlanTextField: UITextField!
    @IBOutlet weak var nextAppointmentTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    var appointmentID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func doneButtonTapped() {
        
        ProgressHUD.show()
        let formData = ["วินิจฉัย":diagnoseTextField.text,
                        "แผนการรักษา":carePlanTextField.text,
                        "นัดครั้งถัดไป":nextAppointmentTextField.text]
        
        let payload = ["appointmentID": self.appointmentID,
                       "type": "post",
                       "images": [],
                       "form": formData ] as [String : Any]
        
        functions.httpsCallable("app-appointments-updateForm").call(payload) { result, error in
            ProgressHUD.dismiss()
            
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .appointment
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })

        }
    }


}
