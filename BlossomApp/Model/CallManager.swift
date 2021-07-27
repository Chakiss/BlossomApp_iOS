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

protocol CallManagerDelegate: AnyObject {
    func callManagerDidEndCall()
    func callManagerDidReceivedRemoteVideoTrack(videoTrack: CallVideoTrack)
}

class CallManager: NSObject {
    
    static let manager: CallManager = CallManager()
    private(set) var session: ConnectyCubeCalls.CallSession?
    private var callUUID: UUID?
    private var backgroundTask: UIBackgroundTaskIdentifier?
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
            self.callUUID = UUID()
        }
    }
    
    func startCall() {
        guard let callUUID = self.callUUID else {
            return
        }
        
        session?.startCall(["key":"value"])
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
    
    private func handleIncomingSession(_ session: CallSession) {
        
        self.session = session
        
        self.callUUID = UUID()
        var opponentIDs: [Int] = [session.initiatorID.intValue]
        for userID in session.opponentsIDs {
            guard userID.uintValue != 12345 else {
                continue
            }
            
            opponentIDs.append(userID.intValue)
        }
        
        CallKitAdapter.shared.reportIncomingCall(with: opponentIDs, session: session, uuid: self.callUUID!, onAcceptAction: {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.modalPresentationStyle = .fullScreen
            UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)

        })
        
    }

    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        //4554340 , 4610393
        if let customer = CustomerManager.sharedInstance.customer {
            let connectyID = UInt(customer.referenceConnectyCubeID! as String)! as UInt
            Chat.instance.connect(withUserID: connectyID, password: customer.id!) { (error) in
                print(error)
            }
        }
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
        
        handleIncomingSession(session)
    }
    
    func session(_ session: CallBaseSession, startedConnectingToUser userID: NSNumber) {
        debugPrint("startedConnectingToUser \(userID)")
    }
    
    func session(_ session: CallBaseSession, connectedToUser userID: NSNumber) {
        debugPrint("connectedToUser \(userID)")
        if (session as! CallSession).id == self.session!.id {
            if let callUUID = self.callUUID {
                CallKitAdapter.shared.updateCall(with: callUUID, connectedAt: Date())
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
