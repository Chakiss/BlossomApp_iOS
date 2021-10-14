//
//  CallKitAdapter.swift
//  sample-videochat-swift
//
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import CallKit

import ConnectyCube
import ConnectyCubeCalls

extension Dictionary {
    
    func toCallKitAdapterUserInfo() -> CallKitAdapter.UserInfo {
        let callerName: String = (self["callerName" as! Key] as? String) ?? ""
        let doctorDocID: String = (self["appointmentDoctor" as! Key] as? String) ?? ""
        let customerDocID: String = (self["appointmentCustomer" as! Key] as? String) ?? ""
        let startTimestamp: Int64 = Int64(self["appointmentSessionStartTimestamp" as! Key] as? String ?? "") ?? 0
        let endTimestamp: Int64 = Int64(self["appointmentSessionEndTimestamp" as! Key] as? String ?? "") ?? 0
        let appointmentID: String = (self["appointment" as! Key] as? String) ?? ""
        
        return CallKitAdapter.UserInfo(
            callerName: callerName,
            doctorDocID: doctorDocID,
            customerDocID: customerDocID,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            appointmentID: appointmentID)
    }
    
}

class CallKitAdapter: NSObject, CXProviderDelegate {
    
    struct UserInfo {
        let callerName: String
        let doctorDocID: String
        let customerDocID: String
        let startTimestamp: Int64
        let endTimestamp: Int64
        let appointmentID: String
        
        func dict() -> [String: String] {
            return [
                "callerName": callerName,
                "appointmentDoctor": doctorDocID,
                "appointmentCustomer": customerDocID,
                "appointmentSessionStartTimestamp": "\(startTimestamp)",
                "appointmentSessionEndTimestamp": "\(endTimestamp)",
                "appointment": appointmentID
            ]
        }
    }
    
    open var onMicrophoneMuteAction: (() -> Void)?
    public static let shared = CallKitAdapter()
    
    fileprivate static let kDefaultMaximumCallsPerCallGroup = 1
    fileprivate static let kDefaultMaximumCallGroup = 1
    
    private var callStarted: Bool
    private var provider: CXProvider
    private var callController: CXCallController
    private var session: CallSession?
    private var userInfo: UserInfo?
    private var actionCompletionBlock: (() -> Void)?
    private var onAcceptActionBlock: ((_ userInfo: UserInfo) -> Void)?
    
    private static func configuration() -> CXProviderConfiguration {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let config = CXProviderConfiguration(localizedName: appName ?? "")
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = kDefaultMaximumCallsPerCallGroup
        config.maximumCallGroups = kDefaultMaximumCallGroup
        config.supportedHandleTypes = Set(arrayLiteral: .generic)
        // optional configs
        //config.iconTemplateImageData = UIImage(named: "CallKitLogo")!.pngData()
        //config.ringtoneSound = "ringtone.wav"
        return config
    }
    
    // MARK: - Initialization
    
    override init() {
        callStarted = false
        provider = CXProvider(configuration: CallKitAdapter.configuration())
        callController = CXCallController(queue: DispatchQueue.main)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Call management
    
    open func startCall(with userIDs: [Int], name: String, session: CallSession, uuid: UUID) {
        self.session = session
        let handle = self.handleForUserIDs(userIDs)
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.contactIdentifier = uuid.uuidString
        
        let transaction = CXTransaction(action: action)
        self.requestTransaction(transaction) { (succeed) in
            let update = CXCallUpdate()
            update.remoteHandle = handle
            update.localizedCallerName = name
            update.supportsHolding = false
            update.supportsGrouping = false
            update.supportsUngrouping = false
            update.supportsDTMF = false
            update.hasVideo = session.conferenceType == .video
            self.provider.reportCall(with: uuid, updated: update)
        }
    }
    
    open func endCall(with uuid: UUID, completion: (() -> Void)? = nil) {
        guard self.session != nil else {
            return
        }
        
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        
        dispatchOnMainThread {
            self.requestTransaction(transaction)
        }
        
        self.actionCompletionBlock = completion
    }
    
    open func reportIncomingCall(with userIDs: [Int], name: String, session: CallSession, userInfo: UserInfo, uuid: UUID, onAcceptAction: @escaping (_ userInfo: UserInfo) -> Void, completion: (() -> Void)? = nil) {
        
        //guard self.session == nil else {
        //    return
       // }
        
        self.session = session
        self.userInfo = userInfo
        self.onAcceptActionBlock = onAcceptAction
        
        let update = CXCallUpdate()
        update.remoteHandle = self.handleForUserIDs(userIDs)
        update.localizedCallerName = name
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = session.conferenceType == .video
        
        print("[CallKitAdapter] Activating audio session.")
        let audioSession = CallAudioSession.instance()
        audioSession.useManualAudio = true
        audioSession.currentAudioDevice = .speaker
        // disabling audio unit for local mic recording in recorder to enable it later
        session.recorder?.isLocalAudioEnabled = false
        if (!audioSession.isInitialized) {
            audioSession.initialize { (conf) in
                // adding blutetooth support and airplay support
                conf.categoryOptions = [conf.categoryOptions, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
            }
        }
        
        self.provider.reportNewIncomingCall(with: uuid, update: update) { (error) in
            self.dispatchOnMainThread {
                completion?()
            }
        }
    }
    
    open func updateCall(with uuid: UUID, connectingAt date: Date) {
        self.provider.reportOutgoingCall(with: uuid, startedConnectingAt: date)
    }
    
    open func updateCall(with uuid: UUID, connectedAt date: Date) {
        self.provider.reportOutgoingCall(with: uuid, connectedAt: date)
    }
    
    // MARK: - CXProviderDelegate protocol
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard self.session != nil else {
            action.fail()
            return
        }
        
        dispatchOnMainThread { [weak self] in
            self?.session?.startCall( self?.userInfo?.dict() ?? [:] )
            self?.callStarted = true
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard self.session != nil else {
            action.fail()
            return
        }
        
        if Int(UIDevice.current.systemVersion) == 10 {
            // Workaround for webrtc on ios 10, because first incoming call does not have audio
            // due to incorrect category: AVAudioSessionCategorySoloAmbient
            // webrtc need AVAudioSessionCategoryPlayAndRecord
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        }
        
        dispatchOnMainThread { [weak self] in
            self?.session!.acceptCall( self?.userInfo?.dict() ?? [:] )
            self?.callStarted = true
            action.fulfill()
            
            if let completion = self?.onAcceptActionBlock,
               let info = self?.userInfo {
                completion(info)
                self?.onAcceptActionBlock = nil
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard self.session != nil else {
            action.fail()
            return
        }
        
        let session = self.session
        self.session = nil
        
        dispatchOnMainThread {
            let audioSession = CallAudioSession.instance()
            audioSession.isAudioEnabled = false
            audioSession.useManualAudio = false
            
            if self.callStarted {
                session!.hangUp(nil)
                self.callStarted = false
            }
            else {
                session!.rejectCall(nil)
            }
            
            action.fulfill(withDateEnded: Date())
            
            if let completion = self.actionCompletionBlock {
                completion()
                self.actionCompletionBlock = nil
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard self.session != nil else {
            action.fail()
            return
        }
        
        dispatchOnMainThread {
            self.session!.localMediaStream.audioTrack.isEnabled = !action.isMuted
            action.fulfill()
            
            if let completion = self.onMicrophoneMuteAction {
                completion()
            }
        }
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        NSLog("[CallKitAdapter] Activated audio session.")
        let callAudioSession = CallAudioSession.instance()
        callAudioSession.audioSessionDidActivate(audioSession)
        // enabling audio now
        callAudioSession.isAudioEnabled = true
        callAudioSession.currentAudioDevice = .speaker
        // enabling local mic recording in recorder (if recorder is active) as of interruptions are over now
        self.session?.recorder?.isLocalAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        NSLog("[CallKitAdapter] Dectivated audio session.");
        let callAudioSession = CallAudioSession.instance()
        callAudioSession.audioSessionDidDeactivate(audioSession)
        // deinitializing audio session after iOS deactivated it for us
        if (callAudioSession.isInitialized) {
            NSLog("[CallKitAdapter] Deinitializing session in CallKit callback.")
            callAudioSession.deinitialize()
        }
    }
    
    // MARK: - Helpers
    
    private func handleForUserIDs(_ userIDs: [Int]) -> CXHandle {
        let stringUserIDs: [String] = userIDs.compactMap { String($0) }
        return CXHandle(type: .generic, value: stringUserIDs.joined(separator: ", "))
    }
    
    private func requestTransaction(_ transaction: CXTransaction, completion: ((Bool) -> Void)? = nil) {
        self.callController.request(transaction) { (error) in
            if error != nil {
                print("[CallKitAdapter] Error requesting transaction: %@", error!)
            }
            completion?(error == nil)
        }
    }
    
    private func dispatchOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
