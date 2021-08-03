//
//  HistoryAppointmentDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 29/7/2564 BE.
//

import UIKit
import Firebase
import GSImageViewerController

class HistoryAppointmentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var preFromLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet var preImageView: [UIImageView]!
    
    @IBOutlet weak var postFromLabel: UILabel!
    
    
    var appointment: Appointment?
    let storage = Storage.storage()
    
    var profile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ประวัติ"
        CustomerManager.sharedInstance.getCustomerData(uid: appointment?.customerReference?.documentID ?? "") { customer in
            
            self.profile = "ลักษณะผิว" + " : " + (customer?.skinType ?? "") + "\n"
            self.profile += "ลักษณะสิว" + " : " + (customer?.acneType ?? "") + "\n"
            self.profile += "แพ้ยา" + " : " + (customer?.allergicDrug ?? "") + "\n"
            self.profile += "เคยรักษา" + " : " + (customer?.acneCaredDescription ?? "") + "\n"
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if appointment?.attachedImages?.count ?? 0 > 0 {
                return 2
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "ประวัติ"
        } else if section == 1 {
            return "เรื่องที่ปรึกษา"
        } else {
            return "คำวินิจฉัย"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormDetailCell", for: indexPath) as! FormDetailCell
        
        if indexPath.section == 0 {
         
            cell.detailLabel.text = profile
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let preform: [String:Any] = appointment?.preForm ?? ["":""]
                var preformString = ""
                for key in preform.keys {
                    preformString += key + " : " + (preform[key] as! String) + "\n"
                }
                cell.detailLabel.text = preformString
            } else {
                let cellimage = tableView.dequeueReusableCell(withIdentifier: "FormImageCell", for: indexPath) as! FormImageCell
                let imageArray = appointment?.attachedImages ?? []
                for (index, image) in imageArray.enumerated() {
                    let imageRef = storage.reference(withPath: image )
                    imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                        if error == nil {
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    cellimage.preImageView[index].image = img
                                    
                                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                                    cellimage.preImageView[index].addGestureRecognizer(tap)
                                    cellimage.preImageView[index].isUserInteractionEnabled = true
                                    
                                }
                            }
                        } else {
                            cellimage.preImageView[index].image = UIImage(named: "placeholder")
                            
                        }
                    }
                }
                
                return cellimage
            }
            
        } else {
            
            let postform: [String:Any] = appointment?.postForm ?? ["":""]
            var postformString = ""
            for key in postform.keys {
                postformString += key + " : " + (postform[key] as! String) + "\n"
            }
            cell.detailLabel.text = postformString
        }
        
        
        return cell
    }
 
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
        print(sender.view?.tag)
        let imageArray = appointment?.attachedImages ?? []
        var imageString = imageArray[sender.view?.tag ?? 0]
        
        let imageRef = storage.reference(withPath: imageString )
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        let imageInfo   = GSImageInfo(image: img, imageMode: .aspectFit)
                        let transitionInfo = GSTransitionInfo(fromView: self.tableView)
                        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                        self.present(imageViewer, animated: true, completion: nil)
                        
                    }
                }
            }
        }
       
    }

}
