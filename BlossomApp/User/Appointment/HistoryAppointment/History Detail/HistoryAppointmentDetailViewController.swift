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
import SwiftPhotoGallery
import FirebaseStorageUI

class HistoryAppointmentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var appointmentLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var appointment: Appointment?
    let storage = Storage.storage()
    
    var profile = ""
    var index: Int = 0
    var imageLoadedArray: [UIImage] = []
    
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
            
            //self.userImageView.image = UIImage(named: "placeholderHero")
            
                               
            

                               
           
            
            let imageRef = self.storage.reference().child(customer?.displayPhoto ?? "")
            let placeholderImage = UIImage(named: "placeholder")
            self.userImageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
                
            
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
        dateFormater.dateFormat = "yyyy-MM-dd"
        let dateOfBirth = dateFormater.date(from: date)
        
        let calender = Calendar(identifier: .gregorian)
        
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
 
   

}

extension HistoryAppointmentDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let preform: [String:Any] = appointment?.preForm ?? ["":""]
        let imageArray = preform["attachedImages"] as! [String]
        return  imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PreFormImage = (collectionView.dequeueReusableCell(withReuseIdentifier: "PreFormImage", for: indexPath) as! PreFormImage)
        
        let preform: [String:Any] = appointment?.preForm ?? ["":""]
        let imageArray: [String] = preform["attachedImages"] as! [String]
        
        let imageRef = self.storage.reference().child(imageArray[indexPath.row])
        let placeholderImage = UIImage(named: "placeholder")
        cell.imageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        


        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.66, blue: 0.875, alpha: 1.0)
        gallery.hidePageControl = false
        gallery.modalPresentationStyle = .custom
        gallery.transitioningDelegate = self


        present(gallery, animated: true, completion: { () -> Void in
            gallery.currentPage = self.index
        })
    }
}

// MARK: SwiftPhotoGalleryDataSource Methods
extension HistoryAppointmentDetailViewController: SwiftPhotoGalleryDataSource {

    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return self.imageLoadedArray.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
       return self.imageLoadedArray[forIndex]
        
    }
}


// MARK: SwiftPhotoGalleryDelegate Methods
extension HistoryAppointmentDetailViewController: SwiftPhotoGalleryDelegate {

    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.index = gallery.currentPage
        dismiss(animated: true, completion: nil)
    }
}
