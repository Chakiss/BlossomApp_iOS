//
//  SlotTimeViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 19/7/2564 BE.
//

import UIKit
import Firebase
import SwiftDate

class SlotTimeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var doctor: Doctor?
    
    let db = Firestore.firestore()
    
    var slotDay: [SlotDay] = []
    
    var slotTime: [SlotTime] = []
    
    @IBOutlet weak var dayCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    
    @IBOutlet weak var makeAppointmentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "เลือกเวลาปรึกษาแพทย์"

        makeAppointmentButton.layer.cornerRadius = 22
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        db.collection("doctors").document((doctor?.id)!).collection("slots").getDocuments { daySlot, error in
            if error == nil {
                self.slotDay = (daySlot!.documents.map { queryDocumentSnapshot -> SlotDay in
                    let id = queryDocumentSnapshot.documentID
                    return SlotDay(id: id)
                })
                self.dayCollectionView.reloadData()
                if self.slotDay.count > 0 {
                    self.slotDay[0].isSelected = true
                    self.getSlotTime(dayID: self.slotDay[0].id!)
                }
                
            }
        }
        
    }
    
    func getSlotTime(dayID: String) {
        db.collection("doctors").document((doctor?.id)!).collection("slots").document(dayID).collection("times").getDocuments { timeSlot, error in
            if error == nil {
                
                self.slotTime = (timeSlot!.documents.map { queryDocumentSnapshot -> SlotTime in
                    let id = queryDocumentSnapshot.documentID
                    //let data = queryDocumentSnapshot.data()
                    return SlotTime(id: id)
                })
                //let data = queryDocumentSnapshot.data()
                
                if self.slotTime.count > 0 {
                    self.slotTime[0].isSelected = true
                }
                self.timeCollectionView.reloadData()

                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dayCollectionView {
            return self.slotDay.count
        } else {
            return self.slotTime.count
        }
        
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == dayCollectionView {
            
            
            let slotDay = self.slotDay[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotDateCell", for: indexPath) as! SlotDateCell
            
            let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaBangkok, locale: Locales.thai)
            let date = slotDay.id?.toDate(region: region)
            let day : Int = date!.day
            cell.dayLabel.text = String(day)
            cell.monthLabel.text = date?.monthName(.short)
            
            if slotDay.isSelected == false {
                cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary
                cell.removeShadow()
            } else {
                cell.backgroundCellView.backgroundColor = UIColor.red
                cell.addShadow()
            }
            return cell
            
        } else {
            
            let slotTime = self.slotTime[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotTimeCell", for: indexPath) as! SlotTimeCell
            cell.timeLabel.text = self.slotTime[indexPath.row].id
            
            if slotTime.isSelected == false {
                cell.backgroundCellView.backgroundColor = UIColor.blossomPrimary
                cell.removeShadow()
            } else {
                cell.backgroundCellView.backgroundColor = UIColor.red
                cell.addShadow()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dayCollectionView {
            for index in 0...self.slotDay.count-1 {
                self.slotDay[index].isSelected = false
            }
            self.slotDay[indexPath.row].isSelected = true
            getSlotTime(dayID: self.slotDay[indexPath.row].id!)
            collectionView.reloadData()
        }
        else {
            
            for index in 0...self.slotTime.count-1 {
                self.slotTime[index].isSelected = false
            }
            self.slotTime[indexPath.row].isSelected = true
            collectionView.reloadData()
        }
    }

    @IBAction func makeAppointmentButtonTapped() {
        
    }

}
