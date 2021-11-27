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
import AlignedCollectionViewFlowLayout
import FirebaseStorageUI

class PreFormViewController: UIViewController {
      
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var topicButton: DLRadioButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var imageArray: [UIImage] = []
        
    @IBOutlet weak var collectionView: UICollectionView!
    private var pickerManager: ImagePickerManager?

    var appointmentID: String = ""
    let storage = Storage.storage()
    
    var doctor: Doctor?
    var slotDaySelected: SlotDay?
    var slotTimeSelected: SlotTime?
    
    var attachImage: [String] = []
    var formData: [String:String] = [:]
    
    var appointment: Appointment?
    
    var isEditMode:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topicButton.isMultipleSelectionEnabled = true
        self.submitButton.layer.cornerRadius = 22
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(
            horizontalAlignment: .left,
            verticalAlignment: .top
        )
        alignedFlowLayout.minimumInteritemSpacing = 10
        alignedFlowLayout.itemSize = CGSize(width: 100, height: 100)
        collectionView.collectionViewLayout = alignedFlowLayout

        if isEditMode == true {
            submitButton.setTitle("บันทึก", for: .normal)
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if appointment != nil {
            self.appointmentID = appointment?.id ?? ""
            let preform: [String:Any] = appointment?.preForm ?? [:]

            let topicString = (preform["เรื่องที่ปรึกษา"] as? String) ?? ""
            let arrayTopic = topicString.components(separatedBy: ",")
            for topic in arrayTopic {
                for button in topicButton.otherButtons {
                    if topic == "สิว" {
                        topicButton.isSelected = true
                    } else if topic == button.titleLabel?.text {
                        button.isSelected = true
                    }
                }
            }

            let attachedImageArray: [String] = (preform["attachedImages"] as? [String]) ?? []
            
            for imageData in attachedImageArray {
                let imageView = UIImageView()
                let imageRef = self.storage.reference().child(imageData)
                imageView.sd_setImage(with: imageRef, placeholderImage: nil) { img, error, type, ref in
                    if img != nil {
                        self.imageArray.append(img!)
                        self.collectionView.reloadData()
                    }
                }
            }
            
        }
    }
    
    
    @IBAction func submit() {
        
        
        var selectedButton:String = ""
        for button in topicButton.selectedButtons() {
            if let title = button.titleLabel?.text {
                if selectedButton.isEmpty {
                    selectedButton = title
                } else {
                    selectedButton += ",\(title)"
                }
            }
        }
        
        formData = ["เรื่องที่ปรึกษา":selectedButton]
        
        attachImage = []
        
        for image in imageArray {
            if let imageData = image.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                attachImage.append(encodeString)
            }
        }
        
        
        var isNeedImage = false
        
        if appointment != nil {
            if attachImage.count > 0  {
                isNeedImage = true
            }
        } else {
            let calendar = Calendar.current

            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: slotDaySelected?.date?.dateValue() ?? Date())
            let date2 = calendar.startOfDay(for: Date())

            let components = calendar.dateComponents([.day], from: date1, to: date2)
            
            if abs(components.day!) < 7 {
                isNeedImage = true
            }
            
        }
        
        
        if isNeedImage == true {
            
            if appointment != nil {
                
                self.updateForm()
                
            } else {
                
                showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาแนบรูปอย่างน้อย 1 รูป") {}
            }
            
        } else {
            if appointment != nil {
                
            } else {
                let alert = UIAlertController(title: "ยืนยัน", message: "คุณต้องการที่จะนัดหมายในเวลานี้ใช่หรือไม่​?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ยกเลิก", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "ยืนยัน", style: .default, handler: { [weak self] _ in
                    ProgressHUD.show()
                    
                    guard let self = self else { return }
                    let payload = ["doctorID": self.doctor?.id,
                                   "slotID": self.slotDaySelected?.id,
                                   "timeID": self.slotTimeSelected?.id ]
                    
                    self.functions.httpsCallable("app-orders-createAppointmentOrder").call(payload) { [weak self] result, error in
                        
                        ProgressHUD.dismiss()
                        guard let self = self else { return }
                        
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
                                                { [weak self] (granted: Bool, error: Error?) -> Void in
                        if granted {
                            self?.insertEvent(store: eventStore)
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
            
            functions.httpsCallable("app-appointments-updateForm").call(payload) { [weak self] result, error in
                ProgressHUD.dismiss()
                
                guard let self = self else { return }
                if self.appointment != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
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
    }
    
}

extension PreFormViewController : UpdateCartViewControllerDelegate {
    
    func appointmentOrderSuccess(orderID: String) {
        self.navigationController?.popViewController(animated: true)
        makeAppointmentOrderPaid(orderID: orderID)
    }
    
}


extension PreFormViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let cell: ImageCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell)
        if indexPath.row < imageArray.count {
            cell?.imageView.image = imageArray[indexPath.row]
        } else {
            cell?.imageView.image = UIImage(named: "image-upload")
        }
    
        return cell ?? UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == imageArray.count   {
            pickerManager = ImagePickerManager()
            pickerManager?.pickImage(self) { [weak self] image in
                //print(image)
                self?.imageArray.append(image)
                self?.collectionView.reloadData()
            }
        } else {
            let alert = UIAlertController(title: "ลบรูป", message: "คุณต้องการลบรูปใช่หรือไม่ ?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in

            }))
            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { [weak self] _ in
                self?.imageArray.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
}
