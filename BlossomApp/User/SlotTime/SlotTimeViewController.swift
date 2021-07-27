//
//  SlotTimeViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 19/7/2564 BE.
//

import UIKit
import Firebase
import SwiftDate
import EventKit

class SlotTimeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var doctor: Doctor?
    
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    
    var slotDay: [SlotDay] = []
    var slotTime: [SlotTime] = []
    
    var slotDaySelected: SlotDay?
    var slotTimeSelected: SlotTime?
    
    @IBOutlet weak var dayCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    
    @IBOutlet weak var makeAppointmentButton: UIButton!
    @IBOutlet weak var salePriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "เลือกเวลาปรึกษาแพทย์"

        makeAppointmentButton.layer.cornerRadius = 22
        
        
        makeAppointmentButton.backgroundColor = UIColor.blossomLightGray
        makeAppointmentButton.isEnabled = false
        
        salePriceLabel.text = ""
        // Do any additional setup after loading the view.
        
       
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        db.collection("doctors").document((doctor?.id)!).collection("slots").getDocuments { daySlot, error in
            if error == nil {
                self.slotDay = (daySlot!.documents.map { queryDocumentSnapshot -> SlotDay in
                    let id = queryDocumentSnapshot.documentID
                    return SlotDay(id: id)
                })
                self.dayCollectionView.reloadData()
                if self.slotDay.count > 0 {
                    self.slotDaySelected = self.slotDay[0]
                    self.getSlotTime(dayID: self.slotDay[0].id!)
                }
                
            }
        }
        
    }
    
    func getSlotTime(dayID: String) {
        db.collection("doctors").document((doctor?.id)!).collection("slots").document(dayID).collection("times").getDocuments { timeSlot, error in
            if error == nil {
                
                self.slotTime = (timeSlot!.documents.map { queryDocumentSnapshot -> SlotTime in
                    let id = queryDocumentSnapshot.documentID
                    let data = queryDocumentSnapshot.data()
                    let isBooked = data["isBooked"] as? Bool ?? false
                    let isCompleted = data["isCompleted"]as? Bool ?? false
                    let isLocked = data["isLocked"]as? Bool ?? false
                    let isPaid = data["isPaid"]as? Bool ?? false
                    let period = data["period"]as? Int ?? 0
                    let salePrice = data["salePrice"]as? Int ?? 0
                    let start = data["start"]as? Timestamp ?? Timestamp()
                    let end = data["end"]as? Timestamp ?? Timestamp()
                    
                    return SlotTime(id: id, isBooked: isBooked, isCompleted: isCompleted, isLocked: isLocked, isPaid: isPaid, period: period, salePrice: salePrice, start: start, end: end)
                })
                if self.slotTime.count > 0 {
                   //self.slotTimeSelected = self.slotTime[0]
                }
                self.timeCollectionView.reloadData()

                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dayCollectionView {
            return self.slotDay.count
        } else {
            return self.slotTime.count
        }
        
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == dayCollectionView {
            
            
            let slotDay = self.slotDay[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotDateCell", for: indexPath) as! SlotDateCell
            
            let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaBangkok, locale: Locales.thai)
            let date = slotDay.id?.toDate(region: region)
            let day : Int = date!.day
            cell.dayLabel.text = String(day)
            cell.monthLabel.text = date?.monthName(.short)
            
            if self.slotDaySelected?.id == slotDay.id {
                cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary
                cell.removeShadow()
            } else {
                cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary3
                cell.addShadow()
            }
            return cell
            
        } else {
            
            let slotTime = self.slotTime[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotTimeCell", for: indexPath) as! SlotTimeCell
            cell.timeLabel.text = self.slotTime[indexPath.row].id
            
            
            if slotTime.isBooked == false{
                if self.slotTimeSelected?.id == slotTime.id {
                    cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary
                    
                } else {
                    cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary3
                    
                }
                
            } else {
                cell.backgroundCellView.backgroundColor = UIColor.blossomLightGray
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dayCollectionView {
            self.slotDaySelected = self.slotDay[indexPath.row]
            getSlotTime(dayID: self.slotDay[indexPath.row].id!)
            collectionView.reloadData()
            self.slotTimeSelected = nil
            checkAppointmentButton()
        }
        else {
            let slotTime = self.slotTime[indexPath.row]
            if slotTime.isBooked == false{
                self.slotTimeSelected = self.slotTime[indexPath.row]
                collectionView.reloadData()
                checkAppointmentButton()
            } else {
                return
            }
        }
    }

    func checkAppointmentButton() {
        if self.slotTimeSelected?.isBooked == false && self.slotTimeSelected?.isCompleted == false && self.slotTimeSelected?.isLocked == false && self.slotTimeSelected?.isPaid == false {
            let price = (self.slotTimeSelected?.salePrice!)! as Int
            salePriceLabel.text = ("\(price) บาท")
            makeAppointmentButton.backgroundColor = UIColor.blossomPrimary
            makeAppointmentButton.isEnabled = true
        } else {
            
            makeAppointmentButton.backgroundColor = UIColor.blossomLightGray
            makeAppointmentButton.isEnabled = false
        }
        
    }
    
    @IBAction func makeAppointmentButtonTapped() {
        
        ProgressHUD.show()
    
        let payload = ["doctorID": doctor?.id,
                       "slotID":self.slotDaySelected?.id,
                       "timeID":self.slotTimeSelected?.id ]
        
        functions.httpsCallable("app-orders-createAppointmentOrder").call(payload) { result, error in
        
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
                
                
                if let appointmentID = appointment["appointmentID"] {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "PreFormViewController") as! PreFormViewController
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.appointmentID = appointmentID
                    self.navigationController?.present(viewController, animated: true, completion: nil)
                }
                

                
            }

        }
    }

    func insertEvent(store: EKEventStore) {
        
        let messageString = "มีนัดกับ " + ((doctor?.displayName ?? "") as String)
          let event:EKEvent = EKEvent(eventStore: store)
          let startDate = Date()
        
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
    
}

extension SlotTimeViewController : UpdateCartViewControllerDelegate {
    
    func appointmentOrderSuccess(orderID: String) {
        self.navigationController?.popViewController(animated: true)
        makeAppointmentOrderPaid(orderID: orderID)
    }
    
}
