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

class PostFromViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var diagnoseTextField: UITextField!
    @IBOutlet weak var carePlanTextField: UITextField!
    @IBOutlet weak var nextAppointmentTextField: UITextField!
    @IBOutlet weak var medicineTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var functions = Functions.functions()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var appointmentID: String = ""
    var customerDocID: String = ""
    var appointment: Appointment?
    weak var delegate: PostFromViewControllerDelegate?
    var attachedImage: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        db.collection("appointments")
            .document(appointmentID)
            .addSnapshotListener { snapshot, error in
                let data = snapshot?.data()
                let doctorRef = data?["doctorReference"]  as? DocumentReference ?? nil
                let timeRef = data?["timeReference"]  as? DocumentReference ?? nil
                let cusRef = data?["customerReference"]  as? DocumentReference ?? nil
                let sessionStart = data?["sessionStart"] as! Timestamp
                let sessionEnd = data?["sessionEnd"]  as! Timestamp
                let isComplete = data?["isCompleted"]  as! Bool
                let preForm = data?["preForm"] as? [String:Any] ?? ["":""]
                let postForm = data?["postForm"] as? [String:Any] ?? ["":""]
                let attacheImage = data?["attachedImages"] as? [String] ?? []
                
                self.appointment = Appointment(id: snapshot?.documentID ?? self.appointmentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm)
                self.appointment?.isComplete = isComplete
                self.appointment?.attachedImages = attacheImage
                
                //self.prepareImage()
            }
               
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func prepareImage(){
        
        
        let imageArray = self.appointment?.attachedImages ?? []
        for imageString in imageArray {
            let imageRef = storage.reference(withPath: imageString )
            imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                if error == nil {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            
                            if let imageData = img.jpeg(.low) {
                                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                                self.attachedImage.append(encodeString)
                            }
                            
                        }
                    }
                }
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
