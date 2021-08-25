//
//  PreFormViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 22/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase
import SwiftDate
import EventKit
import ConnectyCube

class PreFormViewController: UIViewController {
  
    

    
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var topicButton: DLRadioButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    var selectedImage1: Bool = false
    var selectedImage2: Bool = false
    var selectedImage3: Bool = false
    
    var appointmentID: String = ""
    
    var doctor: Doctor?
    var slotDaySelected: SlotDay?
    var slotTimeSelected: SlotTime?
    
    var attachImage: [String] = []
    var formData: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topicButton.isMultipleSelectionEnabled = true
        self.submitButton.layer.cornerRadius = 22
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView1.isUserInteractionEnabled = true
        imageView1.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView2.isUserInteractionEnabled = true
        imageView2.addGestureRecognizer(tapGestureRecognizer2)
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView3.isUserInteractionEnabled = true
        imageView3.addGestureRecognizer(tapGestureRecognizer3)
    
    }
    
    
    
    @IBAction func submit() {
        var image1String = ""
        if selectedImage1 == true {
            if let imageData = imageView1.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image1String = encodeString
                
            }
        }
        
        var image2String = ""
        if selectedImage2 == true {
            if let imageData = imageView2.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image2String = encodeString
            }
        }
        
        var image3String = ""
        if selectedImage3 == true {
            if let imageData = imageView3.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image3String = encodeString
            }
        }
        
        var selectedButton:String = ""
        for button in topicButton.selectedButtons() {
            let title = (button.titleLabel?.text)! as String
            if selectedButton.isEmpty {
                selectedButton = title
               } else {
                selectedButton += ",\(title)"
               }
        }
        
        formData = ["เรื่องที่ปรึกษา":selectedButton]
        
        attachImage = []
        
        if !image1String.isEmpty {
            attachImage.append(image1String)
        }
        
        if !image2String.isEmpty {
            attachImage.append(image2String)
        }
        
        if !image3String.isEmpty {
            attachImage.append(image3String)
        }
        
        if attachImage.count == 0 {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาแนบรูปอย่างน้อย 1 รูป") {}
        }
        else {
            let alert = UIAlertController(title: "ยืนยัน", message: "คุณต้องการที่จะนัดหมายในเวลานี้ใช่หรือไม่​?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ยกเลิก", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "ยืนยัน", style: .default, handler: {_ in
                ProgressHUD.show()
                
                let payload = ["doctorID": self.doctor?.id,
                               "slotID": self.slotDaySelected?.id,
                               "timeID": self.slotTimeSelected?.id ]
                
                self.functions.httpsCallable("app-orders-createAppointmentOrder").call(payload) { result, error in
                    
                    ProgressHUD.dismiss()
                    if error != nil {
                        let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        print(result?.data as Any)
                        let order = result?.data as? [String : String] ?? ["":""]
                        if self.slotTimeSelected?.salePrice == 0 {
                            if let orderID = order["orderID"] {
                                self.makeAppointmentOrderPaid(orderID: orderID)
                            }
                            
                        } else if let orderID = order["orderID"] {
                            // Make Payment
                            let paymentMethodViewController = PaymentMethodViewController.initializeInstance(cart: nil, appointmentOrder: AppointmentOrder(id: orderID, amount: self.slotTimeSelected?.salePrice ?? 0))
                            paymentMethodViewController.delegate = self
                            self.navigationController?.pushViewController(paymentMethodViewController, animated: true)
                        }
                    }
                    
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
         
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        ImagePickerManager().pickImage(self){ image in
            let tappedImage = tapGestureRecognizer.view as! UIImageView
            if tappedImage.tag == 1 {
                self.imageView1.image = image
                self.selectedImage1 = true
            } else if tappedImage.tag == 2 {
                self.imageView2.image = image
                self.selectedImage2 = true
            } else {
                self.imageView3.image = image
                self.selectedImage3 = true
            }
            
        }
    }
    

    func makeAppointmentOrderPaid(orderID: String){
     
        ProgressHUD.show()
        let payload = ["orderID": orderID]
        
        functions.httpsCallable("app-orders-markAppointmentOrderPaid").call(payload) { result, error in
        
            ProgressHUD.dismiss()
            if error != nil {
                let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let appointment = result?.data as? [String : String] ?? ["":""]
                
                // 1
                let eventStore = EKEventStore()
                
                // 2
                switch EKEventStore.authorizationStatus(for: .event) {
                case .authorized:
                    self.insertEvent(store: eventStore)
                case .denied:
                    print("Access denied")
                case .notDetermined:
                    // 3
                    eventStore.requestAccess(to: .event, completion:
                                                {[weak self] (granted: Bool, error: Error?) -> Void in
                                                    if granted {
                                                        self!.insertEvent(store: eventStore)
                                                    } else {
                                                        print("Access denied")
                                                    }
                                                })
                default:
                    print("Case default")
                }
                
                let event = Event()
                event.notificationType = .push

                let recipientID = NSNumber(value:self.doctor?.referenceConnectyCubeID ?? 0)
                event.usersIDs = [recipientID]
                event.type = .oneShot

                let pushmessage = "มีการนัดหมายปรึกษาแพทย์เพิ่มเข้ามา"
                var pushParameters = [String : String]()
                pushParameters["message"] = pushmessage

                if let jsonData = try? JSONSerialization.data(withJSONObject: pushParameters,
                                                              options: .prettyPrinted) {
                    let jsonString = String(bytes: jsonData,
                                            encoding: String.Encoding.utf8)

                    event.message = jsonString

                    Request.createEvent(event, successBlock: {(events) in

                    }, errorBlock: {(error) in

                    })
                }

                
                if let appointmentID = appointment["appointmentID"] {
                    self.appointmentID = appointmentID
                    self.updateForm()

                }
                

                
            }

        }
    }
    
    func insertEvent(store: EKEventStore) {
        
        let messageString = "มีนัดกับ " + ((doctor?.displayName ?? "") as String)
          let event:EKEvent = EKEvent(eventStore: store)
          //let startDate = Date()
        
          event.title = "Blossom App นัดหมาย"
          event.startDate = self.slotTimeSelected?.start?.dateValue()
          event.endDate = self.slotTimeSelected?.end?.dateValue()
          event.notes = messageString
          event.calendar = store.defaultCalendarForNewEvents
          do {
              try store.save(event, span: .thisEvent)
          } catch let error as NSError {
          print("failed to save event with error : \(error)")
          }
          print("Saved Event")
    }


    
    func updateForm(){
        
        if attachImage.count == 0 {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาแนบรูปอย่างน้อย 1 รูป") {}
        } else {
            ProgressHUD.show()
            let payload = ["appointmentID": self.appointmentID,
                           "type": "pre",
                           "images": attachImage,
                           "form": formData ] as [String : Any]
            
            functions.httpsCallable("app-appointments-updateForm").call(payload) { result, error in
                ProgressHUD.dismiss()
                
            }
            self.navigationController?.popToRootViewController(animated: false)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.deeplinking = .appointment
                appDelegate.handleDeeplinking()
                
                self.dismiss(animated: false, completion: {
                    
                })
                
            }
        }
    }
}

extension PreFormViewController : UpdateCartViewControllerDelegate {
    
    func appointmentOrderSuccess(orderID: String) {
        self.navigationController?.popViewController(animated: true)
        makeAppointmentOrderPaid(orderID: orderID)
    }
    
}
