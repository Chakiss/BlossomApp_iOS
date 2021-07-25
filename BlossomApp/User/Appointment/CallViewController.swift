//
//  CallViewController.swift
//  sample-videochat-swift
//
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import QuartzCore

import ConnectyCube
import ConnectyCubeCalls
import SVProgressHUD

class CallViewController: UIViewController, CallClientDelegate {
    
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    @IBOutlet weak var soundBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    open var callUUID: UUID = UUID()
    
    @IBOutlet weak var localVideoView : UIView! // your video view to render local camera video stream
    @IBOutlet weak var opponentVideoView: CallRemoteVideoView!
    var videoCapture: CallCameraCapture?
    var session: CallSession?
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // controller is highly dependent on existing session
        assert(session != nil, "Attempt to instatiate call controller without correct session")
        
        configureUI()
        
        CallClient.instance().add(self)
        
        let videoFormat = CallVideoFormat()
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        // CYBCallCameraCapture class used to capture frames using AVFoundation APIs
        self.videoCapture = CallCameraCapture.init(videoFormat: videoFormat, position: .front)
        
        // add video capture to session's local media stream
        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
        
        self.videoCapture?.previewLayer.frame = self.localVideoView.bounds
        self.videoCapture?.startSession()
        
        self.localVideoView.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
        
        assert(callUUID != nil, "uuid must always be generated whenever callkit is in use")
        CallKitAdapter.shared.updateCall(with: callUUID, connectingAt: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.resumeVideoCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureUI() {
        self.endBtn.layer.cornerRadius = self.endBtn.frame.height / 2
        self.endBtn.clipsToBounds = true
        
        
        self.videoBtn.layer.cornerRadius = self.videoBtn.frame.height / 2
        self.videoBtn.clipsToBounds = true
        self.videoBtn.setImage(UIImage(named: "ic_video_off_white"), for: .selected)
        
        self.camBtn.layer.cornerRadius = self.camBtn.frame.height / 2
        self.camBtn.clipsToBounds = true
        self.camBtn.setImage(UIImage(named: "ic_camera_front"), for: .selected)
        
        self.soundBtn.isHidden = true
        
        self.micBtn.layer.cornerRadius = self.micBtn.frame.height / 2
        self.micBtn.clipsToBounds = true
        self.micBtn.setImage(UIImage(named: "ic_microphone_off_white"), for: .selected)
    }
    // MARK: - Preparations and configurations
    
   
    
//    func configureAudio() {
//
//        let audioSession = CallAudioSession.instance()
//
//        if (!audioSession.isInitialized) {
//            audioSession.initialize { (configuration: CallAudioSessionConfiguration) -> () in
//
//                configuration.categoryOptions = [configuration.categoryOptions, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
//
//                if (self.isVideoCall) {
//                    //configuration.mode =
//                }
//            }
//        }
//    }
//
//    func configureUI() {
//        self.endBtn.layer.cornerRadius = self.endBtn.frame.height / 2
//        self.endBtn.clipsToBounds = true
//
//        if (isVideoCall) {
//            self.videoBtn.layer.cornerRadius = self.videoBtn.frame.height / 2
//            self.videoBtn.clipsToBounds = true
//            self.videoBtn.setImage(UIImage(named: "ic_video_off_white"), for: .selected)
//
//            //self.screenShareBtn.layer.cornerRadius = self.screenShareBtn.frame.height / 2
//            //self.screenShareBtn.clipsToBounds = true
//
//            self.camBtn.layer.cornerRadius = self.camBtn.frame.height / 2
//            self.camBtn.clipsToBounds = true
//            self.camBtn.setImage(UIImage(named: "ic_camera_front"), for: .selected)
//
//            self.soundBtn.isHidden = true
//        }
//        else {
//            self.camBtn.isHidden = true
//            self.screenShareBtn.isHidden = true
//            self.videoBtn.isHidden = true
//
//            self.soundBtn.layer.cornerRadius = self.soundBtn.frame.height / 2
//            self.soundBtn.clipsToBounds = true
//            self.soundBtn.setImage(UIImage(named: "ic_volume_low_white"), for: .selected)
//            if (session!.conferenceType == .audio) {
//                self.soundBtn.isSelected = true
//            }
//            self.soundBtn.isHidden = false
//
//
//        }
//
//        self.micBtn.layer.cornerRadius = self.micBtn.frame.height / 2
//        self.micBtn.clipsToBounds = true
//        self.micBtn.setImage(UIImage(named: "ic_microphone_off_white"), for: .selected)
//    }
    
    // MARK: - Actions
    
    @IBAction func didPressCamSwitchButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        session!.localMediaStream.videoTrack.isEnabled = !sender.isSelected
        self.localVideoView?.isHidden = sender.isSelected
    }
    
    @IBAction func didPressMicSwitchButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        session!.localMediaStream.audioTrack.isEnabled = !sender.isSelected
    }
    
    @IBAction func didPressDynamicButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let audioSession = CallAudioSession.instance()
        audioSession.currentAudioDevice =
            audioSession.currentAudioDevice == .speaker ? .receiver : .speaker
    }
    
    @IBAction func didPressCameraRotationButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.videoCapture?.position = self.videoCapture?.position == .back ? .front : .back
    }
    
    @IBAction func didPressEnd(_ sender: UIButton) {
        
        session!.hangUp(nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressScreenShare(_ sender: UIButton) {
//        self.videoCapture.stopSession(nil)
//        self.performSegue(withIdentifier: "ScreenShareViewController", sender: session)
    }

    
    
    // MARK: - CallClientDelegate protocol
    
    func session(_ session: CallSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        if session.id == self.session!.id {
//            if isVideoCall {
//                self.removeRemoteView(with: userID.uintValue)
//            }
//            if userID == session.initiatorID {
                self.session!.hangUp(nil)
//            }
        }
    }
    
    func session(_ session: CallBaseSession, connectedToUser userID: NSNumber) {
        
        if (session as! CallSession).id == self.session!.id {
            
            //if isInitiator {
                CallKitAdapter.shared.updateCall(with: self.callUUID, connectedAt: Date())
            //}
        }
    }
    
    func session(_ session: CallBaseSession, receivedRemoteVideoTrack videoTrack: CallVideoTrack, fromUser userID: NSNumber) {
       // we suppose you have created UIView and set it's class to RemoteVideoView class
       // also we suggest you to set view mode to UIViewContentModeScaleAspectFit or
       // UIViewContentModeScaleAspectFill
       self.opponentVideoView.setVideoTrack(videoTrack)
    }
    
    func session(_ session: CallBaseSession, didChange state: CallConnectionState, forUser userID: NSNumber) {
//        if (session as! CallSession).id == self.session!.id {
//            if let i = self.views.index(where: { $0.tag == userID.uintValue }) {
//                let view = self.views[i] as! RemoteConnectionView
//                view.connectionState = state
//            }
//        }
    }
    
    func sessionDidClose(_ session: CallSession) {
        
        if session.id == self.session!.id {
            
            CallKitAdapter.shared.endCall(with: self.callUUID)
            
            if self.videoCapture != nil {
                self.videoCapture?.stopSession(nil)
            }
            self.dismiss(animated: true)
        }
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

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
