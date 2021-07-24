//
//  LocalVideoView.swift
//  sample-videochat-swift
//
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import AVFoundation

class LocalVideoView: UIView {
    
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    public init(withPreviewLayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame:.zero)
        
        self.videoLayer = layer
        self.videoLayer!.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(layer, at:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer!.frame = self.bounds
    }

}
