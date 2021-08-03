//
//  PostFromViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 28/7/2564 BE.
//

import UIKit
import Firebase

protocol PostFromViewControllerDelegate: AnyObject {
    func postFormDidFinish(controller: PostFromViewController)
}

class PostFromViewController: UIViewController {

    @IBOutlet weak var diagnoseTextField: UITextField!
    @IBOutlet weak var carePlanTextField: UITextField!
    @IBOutlet weak var nextAppointmentTextField: UITextField!
    @IBOutlet weak var medicineTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    var appointmentID: String = ""
    var customerDocID: String = ""
    
    weak var delegate: PostFromViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let payload = ["appointmentID": appointmentID]
        let functions = Functions.functions()
        
        ProgressHUD.show()
        functions.httpsCallable("app-appointments-markCompleted").call(payload) { [weak self] result, error in
        
            ProgressHUD.dismiss()
            if error != nil {
                let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.presentedViewController?.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    
    @IBAction func doneButtonTapped() {
        
        ProgressHUD.show()
        let formData = ["วินิจฉัย":diagnoseTextField.text,
                        "แผนการรักษา":carePlanTextField.text,
                        "นัดครั้งถัดไป":nextAppointmentTextField.text,
                        "ยาที่ใช้ในการรักษา":medicineTextField.text]
        
        let payload = ["appointmentID": self.appointmentID,
                       "type": "post",
                       "images": [],
                       "form": formData ] as [String : Any]
        
        functions.httpsCallable("app-appointments-updateForm").call(payload) { [weak self] result, error in
            
            ProgressHUD.dismiss()
            guard let self = self else { return }
            self.delegate?.postFormDidFinish(controller: self)
            
        }
    }


}
