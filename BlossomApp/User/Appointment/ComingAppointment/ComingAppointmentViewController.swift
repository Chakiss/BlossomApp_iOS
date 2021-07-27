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

class ComingAppointmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PKPushRegistryDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var session: ConnectyCubeCalls.CallSession?
    private var callUUID: UUID?
    private var pushRegistry: PKPushRegistry!
    private var backgroundTask: UIBackgroundTaskIdentifier!
    
    var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTask = UIBackgroundTaskIdentifier.invalid
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            
            let appointment = self.appointments[indexPath.row]
            appointment.doctorReference?.getDocument(completion: { doctorDocument, error in
                
                let data = doctorDocument?.data()
                let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? Int ?? 0
                let dialog = ChatDialog(dialogID: nil, type: .private)
                
                dialog.occupantIDs = [NSNumber(integerLiteral: referenceConnectyCubeID)]  // an ID of opponent

                Request.createDialog(dialog, successBlock: { (dialog) in
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.deeplinking = .chat
                        appDelegate.handleDeeplinking()
                        self.dismiss(animated: false, completion: {
                            self.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                }) { (error) in

                 }
                
            })
           
        }))
        
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .destructive, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        //         let doctor = self.doctorList[indexPath.row]
        
       
        
    }

    
    
    func attemptCall(with type: CallConferenceType) {
        
        let opponentIDs: [NSNumber] = [ 4611091]
        CallManager.manager.createSession(with: type, opponentIDs: opponentIDs)

       // let newSession = CallClient.instance().createNewSession(withOpponents: opponentIDs as [NSNumber], with: .video)
        
        
//        if let session = CallClient.instance().createNewSession(withOpponents: opponentIDs,
//                                                                with: type) as CallSession? {
//            self.session = session
//
//            self.callUUID = UUID()
            
            let payload = [
                "message" : String(format: "xxxxxx is calling you."),
                "ios_voip" : "1",
                "VOIPCall" : "1",
            ]
            let data = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            let message = String(data: data, encoding: String.Encoding.utf8)
//
//            let event = Event()
//            event.notificationType = .push
//            event.usersIDs = opponentIDs
//            event.type = .oneShot
//            event.message = message
//
//            Request.createEvent(event, successBlock: { (event) in
//                NSLog("Send voip push - Success")
//            }) { (error) in
//                NSLog("Send voip push - Error")
//            }
//
            let event = Event()
            event.notificationType = .push
            event.usersIDs = opponentIDs
            event.type = .oneShot
            
            var pushmessage =  "xxxxxx is calling you."
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
//            session.startCall(["key":"value"])
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.hidesBottomBarWhenPushed = true
        viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
//        }
         
    }
    
    
//    func handleIncomingSession(_ session: CallSession) {
//
//        self.session = session
//
//        self.callUUID = UUID()
//        var opponentIDs: [Int] = [session.initiatorID.intValue]
//        for userID in session.opponentsIDs {
//            guard userID.uintValue != 12345 else {
//                continue
//            }
//
//            opponentIDs.append(userID.intValue)
//        }
//
//        CallKitAdapter.shared.reportIncomingCall(with: opponentIDs, session: session, uuid: self.callUUID!, onAcceptAction: {
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
//            viewController.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(viewController, animated: true)
//
//        })
//
//    }
    
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
