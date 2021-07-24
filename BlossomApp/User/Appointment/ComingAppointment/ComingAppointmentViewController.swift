//
//  ComingAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import PushKit

import ConnectyCube
import ConnectyCubeCalls

class ComingAppointmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CallClientDelegate, PKPushRegistryDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var session: ConnectyCubeCalls.CallSession?
    private var callUUID: UUID?
    private var pushRegistry: PKPushRegistry!
    private var backgroundTask: UIBackgroundTaskIdentifier!
    
    var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTask = UIBackgroundTaskIdentifier.invalid
        
        CallClient.initializeRTC()
        CallClient.instance().add(self)
        
        CallConfig.setAnswerTimeInterval(60)
        // Do any additional setup after loading the view.
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
        
        let alert = UIAlertController(title: "ปรึกษาแพทย์", message: "กรุณาเลือกช่องทางการปรึกษาแพทย์", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "วีดิโอคอล", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            
            
            self.attemptCall(with: .video)

        }))
    
        alert.addAction(UIAlertAction(title: "แชท", style: .default , handler:{ (UIAlertAction)in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.deeplinking = .chat
                appDelegate.handleDeeplinking()
                self.dismiss(animated: false, completion: {
                    self.navigationController?.popToRootViewController(animated: false)
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .destructive, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        //         let doctor = self.doctorList[indexPath.row]
        
       
        
    }

    
    
    func attemptCall(with type: CallConferenceType) {
        
        let opponentIDs: [NSNumber] = [4259292]
        
       // let newSession = CallClient.instance().createNewSession(withOpponents: opponentIDs as [NSNumber], with: .video)
        
        
        if let session = CallClient.instance().createNewSession(withOpponents: opponentIDs,
                                                                with: type) as CallSession? {
            self.session = session
            
            self.callUUID = UUID()
            //CallKitAdapter.shared.startCall(with: opponentIDs as! [Int], session: session, uuid: self.callUUID!)
            
            let payload = [
                "message" : String(format: "xxxxxx is calling you."),
                "ios_voip" : "1",
                "VOIPCall" : "1",
            ]
            let data = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            let message = String(data: data, encoding: String.Encoding.utf8)
            
            let event = Event()
            event.notificationType = .push
            event.usersIDs = opponentIDs
            event.type = .oneShot
            event.message = message
            Request.createEvent(event, successBlock: { (event) in
                NSLog("Send voip push - Success")
            }) { (error) in
                NSLog("Send voip push - Error")
            }
            
         
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.session = self.session
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
         
    }
    
    
    func handleIncomingSession(_ session: CallSession) {
        
        self.session = session
        
        self.callUUID = UUID()
        var opponentIDs: [Int] = [session.initiatorID.intValue]
        for userID in session.opponentsIDs {
            guard userID.uintValue != 12345 else {
                continue
            }
            
            opponentIDs.append(userID.intValue)
        }
//        CallKitAdapter.shared.reportIncomingCall(with: opponentIDs, session: session, uuid: self.callUUID!, onAcceptAction: {
//            self.performSegue(withIdentifier: Segues.callSceneID, sender: self.callUUID)
//        })
    }
    
}

// MARK: - Call Client delegate

extension ComingAppointmentViewController {
    
    func didReceiveNewSession(_ session: CallSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            // already having a session
            return;
        }
        
        handleIncomingSession(session)
    }
    
    func sessionDidClose(_ session: CallSession) {
        guard self.session == session else {
            return
        }
        
        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if UIApplication.shared.applicationState == .background
                && self.backgroundTask == UIBackgroundTaskIdentifier.invalid {
                // dispatching chat disconnect in 1 second so message about call end
                // from webrtc does not cut mid sending
                // checking for background task being invalid though, to avoid disconnecting
                // from chat when another call has already being received in background
                Chat.instance.disconnect(completionBlock: nil)
            }
        }

        //CallKitAdapter.shared.endCall(with: self.callUUID!)
        
        self.callUUID = nil
        self.session = nil
    }
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
            
            //if !Chat.instance.isConnected {
//                Chat.instance.connect(withUserID: "user.id", password: "user.password!"){ (error) in
//                }
           // }
        }
    }
}
