//
//  PostFromViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 28/7/2564 BE.
//

import UIKit
import Firebase
import DLRadioButton

protocol PostFromViewControllerDelegate: AnyObject {
    func postFormDidFinish(controller: PostFromViewController)
}

class PostFromViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var diagnoseButton: DLRadioButton!
    @IBOutlet weak var diagnoseTextField: UITextField!
    @IBOutlet var carePlanButton: DLRadioButton!
    @IBOutlet weak var carePlanTextField: UITextField!
    
    @IBOutlet weak var doxyTextField: UITextField!
    @IBOutlet weak var acnotinTextField: UITextField!
    @IBOutlet weak var amoxicillinTextField: UITextField!
    
    @IBOutlet var carePlanTextView : UITextView!
    @IBOutlet var suggestTextView : UITextView!
    @IBOutlet weak var nextAppointmentTextField: UITextField!
    

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

        self.diagnoseButton.isMultipleSelectionEnabled = true;
        self.carePlanButton.isMultipleSelectionEnabled = true;
        
        self.carePlanTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        self.carePlanTextView.layer.borderWidth = 1.0
        self.carePlanTextView.layer.cornerRadius = 5
        
        self.suggestTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        self.suggestTextView.layer.borderWidth = 1.0
        self.suggestTextView.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        let alert = UIAlertController(title: "แจ้งเตือน", message: "การสนทนาสำเร็จหรือไม่ ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ไม่สำเร็จ", style: .default, handler: {_ in
            self.delegate?.postFormDidFinish(controller: self)
        }))
        alert.addAction(UIAlertAction(title: "สำเร็จ", style: .default, handler: {_ in
            let payload = ["appointmentID": self.appointmentID]
            let functions = Functions.functions()
            
            ProgressHUD.show()
            functions.httpsCallable("app-appointments-markCompleted").call(payload) { result, error in

                ProgressHUD.dismiss()
        
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
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
        var diagnoseString = ""
        for button in diagnoseButton.selectedButtons() {
            if diagnoseString.count > 0 {
                diagnoseString = diagnoseString + " , " + button.titleLabel!.text!
            } else {
                diagnoseString = diagnoseString + button.titleLabel!.text!
            }
        }
        if diagnoseTextField.text?.count ?? 0 > 0 {
            diagnoseString = diagnoseString + (diagnoseTextField.text! )
        }
        
        var carePlanString = ""
        for button in carePlanButton.selectedButtons() {
            var title = button.titleLabel!.text!
            if button.titleLabel!.text! == "Doxy" {
                title =  title + " " + doxyTextField.text! + " สัปดาห์"
            } else if button.titleLabel!.text! == "Acnotin" {
                title = title + " " + acnotinTextField.text! + " สัปดาห์"
            } else if button.titleLabel!.text! == "Amoxicillin" {
                title = title + " " + amoxicillinTextField.text! + " สัปดาห์"
            } else if button.titleLabel!.text! == "อื่น ๆ" {
                title = title + " " + carePlanTextField.text!
            }
            
            if carePlanString.count > 0 {
                carePlanString = carePlanString + " , " + title
            } else {
                carePlanString = carePlanString + title
            }
        }
        
        
        let formData = ["วินิจฉัย": diagnoseString,
                        "การรักษา": carePlanString,
                        "แผนการรักษาเพิ่มเติม": carePlanTextView.text!,
                        "แนะนำคนไข้": suggestTextView.text!,
                        "นัด": nextAppointmentTextField.text! + " สัปดาห์"]
        
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == doxyTextField {
            for button in self.carePlanButton.otherButtons {
                if button.titleLabel!.text! == "Doxy" {
                    button.isSelected = true
                }
            }
        }  else if textField == acnotinTextField {
            for button in self.carePlanButton.otherButtons {
                if button.titleLabel!.text! == "Acnotin" {
                    button.isSelected = true
                }
            }
        } else if textField == amoxicillinTextField {
            for button in self.carePlanButton.otherButtons {
                if button.titleLabel!.text! == "Amoxicillin" {
                    button.isSelected = true
                }
            }
        } else if textField == carePlanTextField {
            for button in self.carePlanButton.otherButtons {
                if button.titleLabel!.text! == "อื่นๆ" {
                    button.isSelected = true
                }
            }
        } else if textField == diagnoseTextField {
            for button in self.diagnoseButton.otherButtons {
                if button.titleLabel!.text! == "อื่นๆ" {
                    button.isSelected = true
                }
            }
        }
    }
}
