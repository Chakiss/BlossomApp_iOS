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
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    var appointmentID: String = ""
    
    weak var delegate: PostFromViewControllerDelegate?
    
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
        
        functions.httpsCallable("app-appointments-updateForm").call(payload) { [weak self] result, error in
            
            ProgressHUD.dismiss()
            guard let self = self else { return }
            self.delegate?.postFormDidFinish(controller: self)
            
        }
    }


}
