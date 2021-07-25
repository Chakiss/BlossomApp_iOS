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

class CallKitAdapter: NSObject, CXProviderDelegate {
    
    open var onMicrophoneMuteAction: (() -> Void)?
    public static let shared = CallKitAdapter()
    
    fileprivate static let kDefaultMaximumCallsPerCallGroup = 1
    fileprivate static let kDefaultMaximumCallGroup = 1
    
    private var callStarted: Bool
    private var provider: CXProvider
    private var callController: CXCallController
    private var session: CallSession?
    private var actionCompletionBlock: (() -> Void)?
    private var onAcceptActionBlock: (() -> Void)?
    
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
    
    open func startCall(with userIDs: [Int], session: CallSession, uuid: UUID) {
        self.session = session
        var contactIdentifier: String = ""
        let handle = self.handleForUserIDs(userIDs, outCallerName: &contactIdentifier)
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.contactIdentifier = contactIdentifier
        
        let transaction = CXTransaction(action: action)
        self.requestTransaction(transaction) { (succeed) in
            let update = CXCallUpdate()
            update.remoteHandle = handle
            update.localizedCallerName = contactIdentifier
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
    
    open func reportIncomingCall(with userIDs: [Int], session: CallSession, uuid: UUID, onAcceptAction: @escaping () -> Void, completion: (() -> Void)? = nil) {
        guard self.session == nil else {
            return
        }
        
        self.session = session
        self.onAcceptActionBlock = onAcceptAction
        
        var callerName = ""
        let update = CXCallUpdate()
        update.remoteHandle = self.handleForUserIDs(userIDs, outCallerName: &callerName)
        update.localizedCallerName = callerName
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = session.conferenceType == .video
        
        print("[CallKitAdapter] Activating audio session.")
        let audioSession = CallAudioSession.instance()
        audioSession.useManualAudio = true
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
        
        dispatchOnMainThread {
            self.session!.startCall(nil)
            self.callStarted = true
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
        
        dispatchOnMainThread {
            self.session!.acceptCall(nil)
            self.callStarted = true
            action.fulfill()
            
            if let completion = self.onAcceptActionBlock {
                completion()
                self.onAcceptActionBlock = nil
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
    
    private func handleForUserIDs(_ userIDs: [Int], outCallerName: inout String) -> CXHandle {
        
        let stringUserIDs: [String] = userIDs.compactMap { String($0) }
        
       // var opponentNames = [String]()
//        for userID in stringUserIDs {
//            let user: User? = Cache.users.object(forKey: userID)
//            user?.fullName != nil ? opponentNames.append(user!.fullName!) : opponentNames.append(userID)
//        }
       // outCallerName = opponentNames.joined(separator: ", ")
        
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