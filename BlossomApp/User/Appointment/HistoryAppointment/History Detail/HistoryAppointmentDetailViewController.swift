//
//  HistoryAppointmentDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 29/7/2564 BE.
//

import UIKit
import Firebase

class HistoryAppointmentDetailViewController: UIViewController {

    @IBOutlet weak var preFromLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet var preImageView: [UIImageView]!
    
    @IBOutlet weak var postFromLabel: UILabel!
    
    
    var appointment: Appointment?
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "นัดหมาย"
        
        //print(appointment)
        let preform: [String:Any] = appointment?.preForm ?? ["":""]
        var preformString = ""
        for key in preform.keys {
            preformString = key + " : " + (preform[key] as! String) + "\n"
        }
        preFromLabel.text = preformString
        
        if let attachedImages = appointment?.attachedImages {
            for (index, imagePath) in attachedImages.enumerated() {
                let imageRef = storage.reference(withPath: imagePath )
                imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                    if error == nil {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.preImageView[index].image = img
                            }
                        }
                    } else {
                        self.preImageView[index].image = UIImage(named: "placeholder")
                        
                    }
                }
                
            }
        } else {
            self.imageStackView.isHidden = true
        }
        
        let postform: [String:Any] = appointment?.postForm ?? ["":""]
        var postformString = ""
        for key in postform.keys {
            postformString = key + " : " + (postform[key] as! String) + "\n"
        }
        postFromLabel.text = postformString
        
    }
    
 

}
