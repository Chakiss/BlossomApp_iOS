//
//  ComingAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import PushKit
import SwiftDate
import ConnectyCube
import ConnectyCubeCalls
import Firebase

class ComingAppointmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PKPushRegistryDelegate {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var session: ConnectyCubeCalls.CallSession?
    private var callUUID: UUID?
    private var pushRegistry: PKPushRegistry!
    private var backgroundTask: UIBackgroundTaskIdentifier!
    
    var appointments: [Appointment] = []
    
    var parentVC: AppointmentListViewController!
    
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTask = UIBackgroundTaskIdentifier.invalid
        tableView.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.appointments.count == 0 {
            if let tabItems = self.tabBarController?.tabBar.items {
                let tabItem = tabItems[2]
                tabItem.badgeValue = nil
            }
        }
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        refreshControl.endRefreshing()
        parentVC?.getAppointmentData()
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         //let doctor = self.doctorList[indexPath.row]
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        cell.appointment = self.appointments[indexPath.row]
        cell.displayAppointment()
         
        return cell
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appointment = self.appointments[indexPath.row]
        
        let alert = UIAlertController(title: "ปรึกษาแพทย์", message: "กรุณาเลือกช่องทางการปรึกษาแพทย์", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "วีดิโอคอล", style: .default, handler: { [weak self] (UIAlertAction) in
            
            let calendar = Calendar.current

            // Replace the hour (time) of both dates with 00:00
            let date1 = appointment.updatedAt?.dateValue() ?? Date()
            let date2 = appointment.sessionStart?.dateValue() ?? Date()

            let components = calendar.dateComponents([.day], from: date1, to: date2)
            
            if abs(components.day!) > 7 {
                self?.showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาอัพเดทรูปที่แนบ") {}
            }
            
            let startDate = appointment.sessionStart?.dateValue() ?? Date()
            let endDate = appointment.sessionEnd?.dateValue() ?? Date()
            
            let now = Date()
            if now >= startDate && now <= endDate {
                self?.attemptCall(with: .video, appointment: appointment)
            } else {
                self?.outofTime()
            }
            
        }))
        
        /*
        alert.addAction(UIAlertAction(title: "แชท", style: .default , handler:{ (UIAlertAction)in
            let payload = ["targetUserID": appointment.doctorReference?.documentID] as [String : Any]
            
            self.functions.httpsCallable("app-messages-createChatChannel").call(payload) { result, error in
                ProgressHUD.dismiss()
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.deeplinking = .chat(id: "")
                    appDelegate.handleDeeplinking()
                    self.dismiss(animated: false, completion: {
                        self.navigationController?.popToRootViewController(animated: false)
                    })
                }
            }
        }))
         */
        
        alert.addAction(UIAlertAction(title: "ติดต่อ Admin เพื่อเปลี่ยนหรือยกเลิกเวลานัด", style: .default, handler: { (UIAlertAction) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MessageingViewController") as! MessageingViewController
            viewController.title = "Admin"
            viewController.customer = CustomerManager.sharedInstance.customer
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//
//                let dialog = ChatDialog(dialogID: nil, type: .private)
//                dialog.occupantIDs = [4663567]  // an ID of opponent
//
//                Request.createDialog(dialog, successBlock: { (dialog) in
//                    appDelegate.deeplinking = .chat(id: "4663567")
//                    appDelegate.handleDeeplinking()
//
//                }) { (error) in
//
//                }
//
//            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "แก้ไข", style: .default, handler:{ (UIAlertAction)in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PreFormViewController") as! PreFormViewController
            viewController.appointment = appointment
            viewController.isEditMode = true
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .destructive, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    func outofTime(){
        let alert = UIAlertController(title: "ขออภัย", message: "คุณอยู่นอกเวลานัดหมาย",         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(_: UIAlertAction!) in}))
        self.present(alert, animated: true, completion: nil)
    }
    func attemptCall(with type: CallConferenceType, appointment: Appointment) {
        
        
        let payload = ["appointmentID": appointment.id!] as [String : Any]
                        
        functions.httpsCallable("app-messages-sendVOIPNotification").call(payload) { result, error in
    
        }
        
        var opponentID = NSNumber(integerLiteral: 0)
        appointment.doctorReference?.getDocument(completion: { snapshot, error in
            let snapshotData = snapshot?.data()
            let connectyCubeID = snapshotData?["referenceConnectyCubeID"] as? Int ?? 0
            opponentID = NSNumber(value:connectyCubeID )
            CallManager.manager.createSession(with: type, opponentIDs: [opponentID])
            
            
            let customerName = "ผู้รับคำปรึกษา " + (CustomerManager.sharedInstance.customer?.firstName ?? "")
            let pushmessage =  "\(customerName) is calling you."
            
            let event = Event()
            event.notificationType = .push
            event.usersIDs = [opponentID]
            event.type = .oneShot
            
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
            
            PushMessage().pushTo(targetID: appointment.doctorReference?.documentID ?? "", type: "chat", subType: "toDoctor", title: "ข้อความ", message: pushmessage, payload: ["":""])
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            
            viewController.callInfo = CallKitAdapter.UserInfo(
                callerName: customerName,
                doctorDocID: appointment.doctorReference?.documentID ?? "",
                customerDocID: appointment.customerReference?.documentID ?? "",
                startTimestamp: appointment.sessionStart?.seconds ?? 0,
                endTimestamp: appointment.sessionEnd?.seconds ?? 0,
                appointmentID: appointment.id ?? ""
            )
            viewController.hidesBottomBarWhenPushed = true
            viewController.modalPresentationStyle = .fullScreen
            viewController.delegate = self
            self.navigationController?.present(viewController, animated: true, completion: nil)
        })
    }
    
}

extension ComingAppointmentViewController: CallViewControllerDelegate {
    
    func callViewDidEndCall(info: CallKitAdapter.UserInfo) {
        CallManager.manager.handleDidEndCall(info: info, controller: self.navigationController)
    }
    
}

// MARK: - Call Client delegate

extension ComingAppointmentViewController {
    
//    func session(_ session: CallBaseSession, receivedRemoteVideoTrack videoTrack: CallVideoTrack, fromUser userID: NSNumber) {
//       // we suppose you have created UIView and set it's class to RemoteVideoView class
//       // also we suggest you to set view mode to UIViewContentModeScaleAspectFit or
//       // UIViewContentModeScaleAspectFill
//
//    }
//
//    func didReceiveNewSession(_ session: CallSession, userInfo: [String : String]? = nil) {
//        if self.session != nil {
//            // already having a session
//            return;
//        }
//
//        handleIncomingSession(session)
//    }
//
//    func session(_ session: CallBaseSession, startedConnectingToUser userID: NSNumber) {
//        debugPrint("startedConnectingToUser \(userID)")
//    }
//
//    func session(_ session: CallBaseSession, connectedToUser userID: NSNumber) {
//        debugPrint("connectedToUser \(userID)")
//    }
//
//    func session(_ session: CallBaseSession, connectionFailedForUser userID: NSNumber) {
//        debugPrint("connectionFailedForUser \(userID)")
//    }
//
//    func session(_ session: CallBaseSession, disconnectedFromUser userID: NSNumber) {
//        debugPrint("disconnectedFromUser \(userID)")
//    }
//
//    func session(_ session: CallBaseSession, connectionClosedForUser userID: NSNumber) {
//        debugPrint("connectionClosedForUser \(userID)")
//    }
//
//    func session(_ session: CallBaseSession, didChange state: CallSessionState) {
//        debugPrint("session didChange \(state.rawValue)")
//    }
//
//    func sessionDidClose(_ session: CallSession) {
//        guard self.session == session else {
//            return
//        }
//
//        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
//            UIApplication.shared.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
//            if UIApplication.shared.applicationState == .background
//                && self.backgroundTask == UIBackgroundTaskIdentifier.invalid {
//                // dispatching chat disconnect in 1 second so message about call end
//                // from webrtc does not cut mid sending
//                // checking for background task being invalid though, to avoid disconnecting
//                // from chat when another call has already being received in background
//                Chat.instance.disconnect(completionBlock: nil)
//            }
//        }
//
//        CallKitAdapter.shared.endCall(with: self.callUUID!)
//
//        self.callUUID = nil
//        self.session = nil
//    }
}

// MARK: - PKPushRegistryDelegate protocol

extension ComingAppointmentViewController {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        
        let sub = Subscription()
        sub.notificationChannel = .APNSVOIP
        sub.deviceUDID = deviceId
        sub.deviceToken = registry.pushToken(for: .voIP)
        Request.createSubscription(sub, successBlock: { (sub) in
            NSLog("Create Subscription request - Success")
        }) { (err) in
            NSLog("Create Subscription request - Error")
        }
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        Request.unregisterSubscription(forUniqueDeviceIdentifier: deviceId, successBlock: {
            NSLog("Unregister Subscription request - Success")
        }) { (err) in
            NSLog("Unregister Subscription request - Error")
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if payload.dictionaryPayload["VOIPCall"] != nil {
            let app = UIApplication.shared
            if app.applicationState == .background
                && self.backgroundTask == UIBackgroundTaskIdentifier.invalid {
                
                self.backgroundTask = app.beginBackgroundTask(expirationHandler: {
                    app.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            
        }
    }
}
