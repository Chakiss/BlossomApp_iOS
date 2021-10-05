//
//  HistoryAppointmentDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 29/7/2564 BE.
//

import UIKit
import Firebase
import GSImageViewerController
import SwiftDate

class HistoryAppointmentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var appointmentLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var appointment: Appointment?
    let storage = Storage.storage()
    
    var profile = ""
    
    @IBOutlet weak var allAppointmentButton: UIButton!
    var isShowAppointmentButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ประวัติ"
        CustomerManager.sharedInstance.getCustomerData(uid: appointment?.customerReference?.documentID ?? "") { customer in
            
            self.profile = "ลักษณะผิว" + " : " + (customer?.skinType ?? "") + "\n"
            self.profile += "ลักษณะสิว" + " : " + (customer?.acneType ?? "") + "\n"
            self.profile += "แพ้ยา" + " : " + (customer?.allergicDrug ?? "") + "\n"
            self.profile += "เคยรักษา" + " : " + (customer?.acneCaredDescription ?? "") + "\n"
            
            self.tableView.reloadData()
            
            self.userNameLabel.text =  customer?.displayName
            
          
            
            self.ageLabel.text = "อายุ " + self.getAgeFromDOF(date: customer?.birthDate! ?? "") + " ปี"
            
            
            let imageRef = self.storage.reference(withPath: customer?.displayPhoto ?? "")
            imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                if error == nil {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.userImageView.image = img
                        }
                    }
                }
            }
        }
        
        let region = Region(calendar: Calendars.buddhist, zone: Zones.asiaBangkok, locale: Locales.thai)
        let startDate = DateInRegion((appointment?.sessionStart?.dateValue())!, region: region)
        let endDate = DateInRegion((appointment?.sessionEnd?.dateValue())!, region: region)
        
        self.appointmentLabel.text = String(format: "วันที่ %2d %@ %d เวลา %.2d:%.2d - %.2d:%.2d",startDate.day,startDate.monthName(.default),startDate.year,startDate.hour,startDate.minute,endDate.hour,endDate.minute)
        
        if isShowAppointmentButton == false {
            self.allAppointmentButton.isHidden = true
        }
        
    }
    
    func getAgeFromDOF(date: String) -> String {//(Int,Int,Int) {
        
        if date.count == 0 { return "" }
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "YYYY-MM-dd"
        let dateOfBirth = dateFormater.date(from: date)
        
        let calender = Calendar.current
        
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
                                                        dateOfBirth!, to: Date())
        
        //return (dateComponent.year!, dateComponent.month!, dateComponent.day!)
        return String(dateComponent.year!)
        
    }

    
    @IBAction func appoointmentAllTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AllAppointmentViewController") as! AllAppointmentViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.customerReference = appointment?.customerReference
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            let imageArray = appointment?.preForm?["attachedImages"] ?? []
            if (imageArray as AnyObject).count > 0 {
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
                    if key != "attachedImages" {
                        preformString += key + " : " + (preform[key] as! String) + "\n"
                    }
                }
                cell.detailLabel.text = preformString
            } else {
                let cellimage = tableView.dequeueReusableCell(withIdentifier: "FormImageCell", for: indexPath) as! FormImageCell
                let preform: [String:Any] = appointment?.preForm ?? ["":""]
                let imageArray: [String] = preform["attachedImages"] as! [String]
                for (index, image) in imageArray.enumerated() {
                    if index > 2 { break }
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
                if key != "attachedImages" {
                    postformString += key + " : " + (postform[key] as! String) + "\n"
                }
            }
            cell.detailLabel.text = postformString
        }
        
        
        return cell
    }
 
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
        
        let preform: [String:Any] = appointment?.preForm ?? ["":""]
        let imageArray: [String] = preform["attachedImages"] as! [String]   
        let imageString = imageArray[sender.view?.tag ?? 0]
        
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
