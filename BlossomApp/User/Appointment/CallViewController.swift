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
import Firebase
import SwiftyUserDefaults

class CallViewController: UIViewController, CallClientDelegate {
    
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    @IBOutlet weak var soundBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
        
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var sessionDuration: UILabel!
    
    @IBOutlet weak var localVideoView : UIView! // your video view to render local camera video stream
    @IBOutlet weak var opponentVideoView: CallRemoteVideoView!

    var callInfo: CallKitAdapter.UserInfo?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // controller is highly dependent on existing session
        
        configureUI()
        
        CallManager.manager.delegate = self
        if let info = callInfo {
            getAppointmentInfo()
            CallManager.manager.startCall(callInfo: info)
        }

        if let videoCapture = CallManager.manager.videoCapture {
            videoCapture.previewLayer.frame = self.localVideoView.bounds
            self.localVideoView.layer.insertSublayer(videoCapture.previewLayer, at: 0)
            videoCapture.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        self.opponentVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        
        configureAudio()
        
//        let event = Event()
//        event.notificationType = .push
//        event.usersIDs = [4554340,4611091 , 4605404]
//        event.type = .oneShot
//
//        var pushmessage = "message.text!" as String
//        var pushParameters = [String : String]()
//        pushParameters["message"] = pushmessage
//
//        if let jsonData = try? JSONSerialization.data(withJSONObject: pushParameters,
//                                                    options: .prettyPrinted) {
//          let jsonString = String(bytes: jsonData,
//                                  encoding: String.Encoding.utf8)
//
//          event.message = jsonString
//
//          Request.createEvent(event, successBlock: {(events) in
//
//          }, errorBlock: {(error) in
//
//          })
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.resumeVideoCapture()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func configureUI() {
        self.endBtn.layer.cornerRadius = self.endBtn.frame.height / 2
        self.endBtn.clipsToBounds = true
        
        self.videoBtn.layer.cornerRadius = self.videoBtn.frame.height / 2
        self.videoBtn.clipsToBounds = true
        self.videoBtn.setImage(UIImage(named: "ic_video_off_white"), for: .selected)
        
        self.camBtn.layer.cornerRadius = self.camBtn.frame.height / 2
        self.camBtn.clipsToBounds = true
        self.camBtn.setImage(UIImage(named: "ic_camera_front"), for: .selected)
        
        self.soundBtn.layer.cornerRadius = self.soundBtn.frame.height / 2
        self.soundBtn.clipsToBounds = true
        self.soundBtn.setImage(UIImage(named: "ic_volume_high_white"), for: .selected)
        if (CallManager.manager.session?.conferenceType == .audio) {
            self.soundBtn.isSelected = true
        }
        self.soundBtn.isHidden = false
        
        self.micBtn.layer.cornerRadius = self.micBtn.frame.height / 2
        self.micBtn.clipsToBounds = true
        self.micBtn.setImage(UIImage(named: "ic_microphone_off_white"), for: .selected)
        
        self.sessionInfoView.layer.cornerRadius = 10
        self.sessionDuration.layer.cornerRadius = 10
        self.sessionInfoView.backgroundColor = UIColor.blossomPrimary3.withAlphaComponent(0.75)
        self.sessionDuration.backgroundColor = UIColor.blossomPrimary3.withAlphaComponent(0.75)
        self.sessionTitleLabel.numberOfLines = 2
        self.sessionTitleLabel.textColor = UIColor.white
        self.sessionDuration.textColor = UIColor.white
        self.sessionTitleLabel.font = FontSize.body.regular()
        self.sessionDuration.font = FontSize.title.bold()
    }
    
    private func getAppointmentInfo() {
        
        guard let info = callInfo else {
            return
        }
        
        let db = Firestore.firestore()

        db.collection("doctors")
            .document(info.doctorDocID)
            .addSnapshotListener { [weak self] snapshotDoctor, error in

                let db = Firestore.firestore()
                db.collection("customers")
                    .document(info.customerDocID)
                    .addSnapshotListener { [weak self] snapshotCustomer, error in

                        let doctorName = "\(snapshotDoctor?["firstName"] as? String ?? "") \(snapshotDoctor?["lastName"] as? String ?? "")"
                        let customerName = "\(snapshotCustomer?["firstName"] as? String ?? "") \(snapshotCustomer?["lastName"] as? String ?? "")"
                        self?.sessionTitleLabel.text = "คุณหมอ: \(doctorName)\nผู้รับคำปรึกษา: \(customerName)"

                    }
            }
        
        sessionDuration.text = "00:00"

    }
    
    // MARK: - Preparations and configurations

    func configureAudio() {
        let audioSession = CallAudioSession.instance()
        audioSession.initialize { (configuration: CallAudioSessionConfiguration) -> () in
            configuration.categoryOptions = [configuration.categoryOptions, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
            configuration.mode = AVAudioSession.Mode.videoChat.rawValue
        }
        //audioSession
    }
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
        CallManager.manager.session?.localMediaStream.videoTrack.isEnabled = !sender.isSelected
        self.localVideoView?.isHidden = sender.isSelected
    }
    
    @IBAction func didPressMicSwitchButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CallManager.manager.session?.localMediaStream.audioTrack.isEnabled = !sender.isSelected
    }
    
    @IBAction func didPressDynamicButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let audioSession = CallAudioSession.instance()
        audioSession.currentAudioDevice =
            audioSession.currentAudioDevice == .speaker ? .receiver : .speaker
    }
    
    @IBAction func didPressCameraRotationButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        CallManager.manager.videoCapture?.position = CallManager.manager.videoCapture?.position == .back ? .front : .back
    }
    
    @IBAction func didPressEnd(_ sender: UIButton) {
        
        CallManager.manager.session?.hangUp(nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func didPressScreenShare(_ sender: UIButton) {
//        self.videoCapture.stopSession(nil)
//        self.performSegue(withIdentifier: "ScreenShareViewController", sender: session)
    }

}

extension CallViewController: CallManagerDelegate {
    
    func callManagerDidEndCall() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func callManagerDidReceivedRemoteVideoTrack(videoTrack: CallVideoTrack) {
        self.opponentVideoView.setVideoTrack(videoTrack)
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
