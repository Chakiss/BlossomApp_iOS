//
//  CallManager.swift
//  BlossomApp
//
//  Created by nim on 27/7/2564 BE.
//

import Foundation
import ConnectyCube
import ConnectyCubeCalls
import PushKit
import SwiftyUserDefaults

protocol CallManagerDelegate: AnyObject {
    func callManagerDidEndCall()
    func callManagerDidReceivedRemoteVideoTrack(videoTrack: CallVideoTrack)
}

class CallManager: NSObject {
    
    var deviceToken: Data?

    static let manager: CallManager = CallManager()
    private(set) var session: ConnectyCubeCalls.CallSession?
    private var callUUID: UUID?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    private(set) var callingStartedAt: Date?
    private(set) var videoCapture: CallCameraCapture?

    weak var delegate: CallManagerDelegate?
    
    private override init() { }
    
    func setupCallManager() {
        Settings.applicationID = 4655
        Settings.authKey = "88p8mWQ9NMcx4SL"
        Settings.authSecret = "XPnwQ5uR5FFJAXj"
        Settings.accountKey = "sdfhdfy2329763buiyi"
        Settings.autoReconnectEnabled = true

        CallClient.initializeRTC()
        CallClient.instance().add(self)
        CallConfig.setAnswerTimeInterval(25)
    }
    
    func createSession(with type: CallConferenceType, opponentIDs: [NSNumber]) {
        if let session = CallClient.instance().createNewSession(withOpponents: opponentIDs, with: type) as CallSession? {
            self.session = session
            let callUUID = UUID()
            self.callUUID = callUUID
            CallKitAdapter.shared.startCall(with: opponentIDs.map({ $0.intValue }), name: "Caller name", session: session, uuid: callUUID)
        }
    }
    
    func startCall(callInfo: CallKitAdapter.UserInfo) {
        guard let callUUID = self.callUUID else {
            return
        }
        
        session?.startCall(callInfo.dict())
        CallKitAdapter.shared.updateCall(with: callUUID, connectingAt: Date())
        
        let videoFormat = CallVideoFormat()
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        self.videoCapture = CallCameraCapture.init(videoFormat: videoFormat, position: .front)
        
        // add video capture to session's local media stream
        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture        
        self.videoCapture?.startSession()
    }
    
    private func handleIncomingSession(_ session: CallSession, userInfo: [String : String]? = nil) {
        self.session = session
        
        self.callUUID = UUID()
        var opponentIDs: [Int] = [session.initiatorID.intValue]
        for userID in session.opponentsIDs {
            guard userID.uintValue != 12345 else {
                continue
            }
            opponentIDs.append(userID.intValue)
        }
        
        let userInfoObject = (userInfo ?? [:]).toCallKitAdapterUserInfo()
        CallKitAdapter.shared.reportIncomingCall(with: opponentIDs, name: userInfoObject.callerName, session: session, userInfo: userInfoObject, uuid: self.callUUID!, onAcceptAction: { info in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.modalPresentationStyle = .fullScreen
            viewController.callInfo = info
            viewController.delegate = self
            UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)

        })
        
    }
    
    func loginConnectyCube(email: String, firebaseID: String, connectyID: UInt) {
        Request.logIn(withUserLogin: email, password: firebaseID, successBlock: { [weak self] (user) in
            print(user)
            self?.createSubscription()
            self?.voipRegistration(connectyID: connectyID, firebaseID: firebaseID)
            
            self?.getDialog()
            
        }) { (error) in
            print(error)
        }
    }
    
    private func voipRegistration(connectyID: UInt, firebaseID: String) {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]

        Chat.instance.connect(withUserID: connectyID, password: firebaseID) { (error) in
            print(error)
        }
    }
    
    private func createSubscription() {
        let subcription = Subscription()
        subcription.notificationChannel = .APNS
        subcription.deviceToken = deviceToken
        subcription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        Request.createSubscription(subcription, successBlock: { (subscriptions) in
            debugPrint("createSubscription APNS \(subscriptions)")
        }) { (error) in
            debugPrint("createSubscription APNS error \(error)")
        }

    }
    
    private func getDialog() {
        Request.dialogs(with: Paginator.limit(100, skip: 0), extendedRequest: nil, successBlock: { (dialogs, usersIDs, paginator) in
            var dialogList:[ChatDialog] = []
            dialogList = dialogs
            var count = 0 as UInt
            for dialog in dialogList {
                count += dialog.unreadMessagesCount
            }
            
            if count > 0 {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if ((appDelegate.window?.rootViewController?.isKind(of:BlossomTabbarController.self)) != nil) {
                        let tabbarVC = appDelegate.window?.rootViewController as! BlossomTabbarController
                        let chatTabbarItem = tabbarVC.tabBar.items?.last
                        chatTabbarItem?.badgeValue = "N"
                        
                    }
                }
            }
            
            
        }) { (error) in
            print(error)
        }
    }
}

extension CallManager : CallViewControllerDelegate {
    
    func callViewDidEndCall(info: CallKitAdapter.UserInfo) {
        let controller = UIApplication.shared.windows.first?.rootViewController
        handleDidEndCall(info: info, controller: controller)
    }
    
    public func handleDidEndCall(info: CallKitAdapter.UserInfo, controller: UIViewController?) {
        
        controller?.dismiss(animated: true, completion: {
            if Defaults[\.role] == "doctor" {
                let storyboard = UIStoryboard(name: "Doctor", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "PostFromViewController") as! PostFromViewController
                viewController.hidesBottomBarWhenPushed = true
                viewController.modalPresentationStyle = .fullScreen
                viewController.appointmentID = info.appointmentID
                viewController.customerDocID = info.customerDocID
                viewController.delegate = self
                controller?.present(viewController, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
                viewController.appointmentID = info.appointmentID
                viewController.hidesBottomBarWhenPushed = true
                viewController.modalPresentationStyle = .fullScreen
                viewController.appointmentID = info.appointmentID
                controller?.present(viewController, animated: true, completion: nil)
            }
            
        })

    }
    
}

extension CallManager: PostFromViewControllerDelegate {
    
    func postFormDidFinish(controller: PostFromViewController) {
        
        guard let presentingViewController = controller.presentingViewController else {
            return
        }
                
        presentingViewController.dismiss(animated: false, completion: {
            if let tabbar = presentingViewController.tabBarController?.selectedViewController as? UINavigationController {
                tabbar.popToRootViewController(animated: false)
            }
        })

        gotoAppointment(customerReferenceID: controller.customerDocID)

    }
    
    private func gotoAppointment(customerReferenceID: String) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .appointment
            appDelegate.handleDeeplinking()
            
            ProgressHUD.show()
            CustomerManager.sharedInstance.getCustomerData(uid: customerReferenceID) { customerData in
                
                ProgressHUD.dismiss()
                if let viewController = ProductListViewController.initializeInstance(customer: customerData, prescriptDelegate: self) {
                    viewController.hidesBottomBarWhenPushed = true
                    let navigation = UINavigationController(rootViewController: viewController)
                    navigation.navigationBar.tintColor = UIColor.white
                    navigation.modalPresentationStyle = .fullScreen
                    UIApplication.shared.windows.first?.rootViewController?.present(navigation, animated: true, completion: nil)
                }

            }
        }
    }
    
}

extension CallManager : ProductListPrescriptionDelegate {
    
    func productListDidFinish() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension CallManager : PKPushRegistryDelegate {
    // Handle updated push credentials

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        print(pushCredentials.token)
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString

        let subscription: Subscription! = Subscription()
        subscription.notificationChannel = NotificationChannel.APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = pushCredentials.token

        Request.createSubscription(subscription, successBlock: { (subscriptions) in
            print(subscriptions)
        }) { (error) in
            print(error)
        }
    }
    
    // MARK: - PKPushRegistryDelegate protocol
   func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
       print("pushRegistry:didInvalidatePushTokenForType:")
   }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("didReceiveIncomingPushWithPayload")
    }

}

extension CallManager : CallClientDelegate {
    
    func session(_ session: CallBaseSession, receivedRemoteVideoTrack videoTrack: CallVideoTrack, fromUser userID: NSNumber) {
       // we suppose you have created UIView and set it's class to RemoteVideoView class
       // also we suggest you to set view mode to UIViewContentModeScaleAspectFit or
       // UIViewContentModeScaleAspectFill
        delegate?.callManagerDidReceivedRemoteVideoTrack(videoTrack: videoTrack)
    }
    
    func didReceiveNewSession(_ session: CallSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            // already having a session
            return;
        }
        
        handleIncomingSession(session, userInfo: userInfo)
    }
    
    func session(_ session: CallBaseSession, startedConnectingToUser userID: NSNumber) {
        debugPrint("startedConnectingToUser \(userID)")
    }
    
    func session(_ session: CallBaseSession, connectedToUser userID: NSNumber) {
        debugPrint("connectedToUser \(userID)")
        if (session as? CallSession)?.id == self.session?.id {
            if let callUUID = self.callUUID, self.callingStartedAt == nil {
                let callingStartedAt = Date()
                self.callingStartedAt = callingStartedAt
                CallKitAdapter.shared.updateCall(with: callUUID, connectedAt: callingStartedAt)
            }
        }
    }
    
    func session(_ session: CallBaseSession, connectionFailedForUser userID: NSNumber) {
        debugPrint("connectionFailedForUser \(userID)")
    }
    
    func session(_ session: CallBaseSession, disconnectedFromUser userID: NSNumber) {
        debugPrint("disconnectedFromUser \(userID)")
        if let s = self.session {
            sessionDidClose(s)
        }
    }

    func session(_ session: CallBaseSession, connectionClosedForUser userID: NSNumber) {
        debugPrint("connectionClosedForUser \(userID)")
    }
    
    func session(_ session: CallBaseSession, didChange state: CallSessionState) {
        debugPrint("session didChange \(state.rawValue)")
    }

    func sessionDidClose(_ session: CallSession) {
        
        guard self.session == session else {
            return
        }
        
        if let backgroundTask = self.backgroundTask, backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
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

        if let callUUID = self.callUUID {
            CallKitAdapter.shared.endCall(with: callUUID)
        }
                
        if session.id == self.session?.id {
            if self.videoCapture != nil {
                self.videoCapture?.stopSession(nil)
            }
        }
        
        self.callingStartedAt = nil
        self.callUUID = nil
        self.session = nil

        delegate?.callManagerDidEndCall()
        
    }
    
    // MARK: - CallClientDelegate protocol
    
    func session(_ session: CallSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if session.id == self.session?.id {
            self.session?.hangUp(nil)
        }
    }
    
    
    func session(_ session: CallBaseSession, didChange state: CallConnectionState, forUser userID: NSNumber) {
        
    }
    
    // MARK: - Helpers
    
    func resumeVideoCapture() {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        if self.videoCapture != nil && self.videoCapture?.hasStarted == true {
            session!.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.videoCapture?.startSession(nil)
        }
    }

    
}
