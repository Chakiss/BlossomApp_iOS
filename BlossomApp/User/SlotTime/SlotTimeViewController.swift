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
import ConnectyCube
import UserNotifications

class SlotTimeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var doctor: Doctor?
    
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    
    var slotDay: [SlotDay] = []
    var slotTime: [SlotTime] = []
    
    var slotDaySelected: SlotDay?
    var slotTimeSelected: SlotTime?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var campaignFirstTime: CampaignFirstTime?
    
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
        super.viewWillAppear(animated)
        
        self.slotDay = []
        
        guard let doctorID = doctor?.id else {
            return
        }
        
        db.collection("doctors")
            .document(doctorID)
            .collection("slots")
            .whereField("platform", isEqualTo: "app")
            .getDocuments { daySlot, error in
                
            guard error == nil else {
                return
            }
                
            guard let slotDocuments = daySlot?.documents else {
                return
            }
                
            for queryDocumentSnapshot in slotDocuments {
                let id = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                let dateTimeStamp = data["date"] as! Timestamp
                
                let region = Region(calendar: Calendar(identifier: .gregorian), zone: Zones.gmt, locale: Locales.englishUnitedStates)
                let today = Date().startOfDay.convertTo(region: region)
                let d = dateTimeStamp.dateValue().convertTo(region: region)
                if d >= today {
                    let slotDay = SlotDay(id: id)
                    slotDay.date = dateTimeStamp
                    self.slotDay.append(slotDay)
                }
                
                //let d = id.toDate("yyyy-MM-dd", region: region)
                //guard let date = d.date, date >= today else {
                //    continue
               // }
            }

            self.dayCollectionView.reloadData()
            
            if self.slotDay.count > 0 {
                self.slotDaySelected = self.slotDay[0]
                self.getSlotTime(dayID: self.slotDay[0].id!)
            }
                
        }
        
        
        
        self.functions.httpsCallable("app-users-getFirstTimeAppointmentCampaign").call(nil) { result, error in
         
            if error == nil {
                if let data = result?.data as? [String: Any] {
                    let price = data["salePrice"] as! Int
                    self.salePriceLabel.text = ("\(price) บาท")
                    self.campaignFirstTime = CampaignFirstTime(isCampaignActivated: data["isCampaignActivated"] as! Bool,
                                                      isFirstTimeUser: data["isFirstTimeUser"] as! Bool,
                                                      salePrice: price)
                }
                
            }
        }
        
    }
    
    func getSlotTime(dayID: String) {
        db.collection("doctors").document((doctor?.id)!)
            .collection("slots").document(dayID)
            .collection("times")
            //.whereField("date", isGreaterThan: Timestamp(date: Date()))
            .getDocuments { timeSlot, error in
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
                    print(Date().timeIntervalSince1970)
                    
                    self.slotTime = self.slotTime.filter({ Int64(Date().timeIntervalSince1970) < $0.start?.seconds ?? 0 })
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
            let date = slotDay.date?.dateValue().convertTo(region: region)//slotDay.id?.toDate(region: region)
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
            
            
            if slotTime.isBooked == false && slotTime.isPaid == false && slotTime.isCompleted == false {
                
                cell.isUserInteractionEnabled = true
                if self.slotTimeSelected?.id == slotTime.id {
                    cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary
                    
                } else {
                    cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary3
                    
                }
                
            } else {
                
                cell.backgroundCellView.backgroundColor = UIColor.blossomLightGray
                cell.isUserInteractionEnabled = false
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
            if slotTime.isBooked == false && slotTime.isPaid == false && slotTime.isCompleted == false {
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
        
        let alert = UIAlertController(title: "ยืนยัน", message: "คุณต้องการที่จะนัดหมายในเวลานี้ใช่หรือไม่​?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "ยืนยัน", style: .default, handler: {_ in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PreFormViewController") as! PreFormViewController
            viewController.doctor = self.doctor
            viewController.slotDaySelected = self.slotDaySelected
            if self.campaignFirstTime?.isCampaignActivated == true {
                if self.campaignFirstTime?.isFirstTimeUser == true {
                    self.slotTimeSelected?.salePrice = self.campaignFirstTime?.salePrice
                }
            }
            
            viewController.slotTimeSelected = self.slotTimeSelected
            self.navigationController?.pushViewController(viewController, animated: true)
         
        }))
        self.present(alert, animated: true, completion: nil)
        

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
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "PreFormViewController") as! PreFormViewController
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.doctor = self.doctor
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
        
      
        scheduleNotification()
    }
    
    func scheduleNotification() {
//        
//        let content = UNMutableNotificationContent() // Содержимое уведомления
//        
//        content.title = notificationType
//        content.body = "This is example how to create"
//        content.sound = UNNotificationSound.default
//        content.badge = 1
//        
//        let date = self.slotTimeSelected?.start?.dateValue() ?? Date()
//        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//        let identifier = "Local Notification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        
//        notificationCenter.add(request) { (error) in
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//            }
//        }
    }

}

extension SlotTimeViewController : UpdateCartViewControllerDelegate {
    
    func appointmentOrderSuccess(orderID: String) {
        self.navigationController?.popViewController(animated: true)
        makeAppointmentOrderPaid(orderID: orderID)
    }
    
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    func hour() -> Int{
        //Get Hour
        let calendar = Calendar.current
        let components = calendar.component(Calendar.Component.hour, from: self)
        let hour = components.hours.hour!
        //Return Hour
        return hour ?? 0
    }
}
