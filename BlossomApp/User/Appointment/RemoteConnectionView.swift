//
//  RemoteConnectionView.swift
//  sample-videochat-swift
//
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit

import ConnectyCubeCalls

class RemoteConnectionView: UIView {
    
    private var nameLabel: UILabel
    private var videoView: CallRemoteVideoView?
    
    open var userName: String? {
        didSet {
            if let userName = userName {
                nameLabel.text = String(format: "%@ - %@", userName, stringFor(connectionState: connectionState))
            }
        }
    }
    open var connectionState: CallConnectionState {
        didSet {
            if let userName = userName {
                nameLabel.text = String(format: "%@ - %@", userName, stringFor(connectionState: connectionState))
            }
            else {
                nameLabel.text = stringFor(connectionState: connectionState)
            }
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        nameLabel = UILabel()
        connectionState = .new
        super.init(frame: CGRect.zero)
        self.addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        var bottomAnchor: NSLayoutYAxisAnchor!
        if #available(iOS 11.0, *) {
            bottomAnchor = self.safeAreaLayoutGuide.bottomAnchor
        }
        else {
            bottomAnchor = self.bottomAnchor
        }
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    convenience init(bgColor: UIColor, textColor: UIColor) {
        self.init()
        self.backgroundColor = bgColor
        nameLabel.textColor = textColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    open func setVideoTrack(_ videoTrack: CallVideoTrack) {
        if videoView == nil {
            videoView = CallRemoteVideoView()
            videoView!.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            videoView!.clipsToBounds = true
            self.insertSubview(videoView!, at: 0)
            
            videoView!.translatesAutoresizingMaskIntoConstraints = false
            videoView!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            videoView!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            videoView!.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            videoView!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
        
        videoView!.setVideoTrack(videoTrack)
    }
    
    // MARK: - Private
    
    private func stringFor(connectionState state: CallConnectionState) -> String {
        
        switch state {
        case .new:
            return "New"
        case .pending:
            return "Pending"
        case .checking, .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .closed:
            return "Closed"
        case .hangUp:
            return "Hang Up"
        case .disconnectTimeout:
            return "Time out"
        case .disconnected:
            return "Disconnected"
        default:
            break;
        }
        
        return "Unknown"
    }
}
