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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "เลือกเวลาปรึกษาแพทย์"

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        db.collection("doctors").document((doctor?.id)!).collection("slots").getDocuments { daySlot, error in
            if error == nil {
                self.slotDay = (daySlot!.documents.map { queryDocumentSnapshot -> SlotDay in
                    let id = queryDocumentSnapshot.documentID
                    let data = queryDocumentSnapshot.data()
                    return SlotDay(id: id)
                })
                self.collectionView.reloadData()
                if self.slotDay.count > 0 {
                    self.getSlotTime(self.slotDay[0].id)
                }
                
            }
        }
        
    }
    
    func getSlotTime(dayID: String) {
        db.collection("doctors").document((doctor?.id)!).collection("slots").document(dayID).collection("times").getDocuments { timeSlot, error in
            if error == nil {
//                self.slotDay = (daySlot!.documents.map { queryDocumentSnapshot -> SlotDay in
//                    let id = queryDocumentSnapshot.documentID
//                    let data = queryDocumentSnapshot.data()
//                    return SlotDay(id: id)
//                })
//                self.collectionView.reloadData()
//                if self.slotDay.count > 0 {
//                    self.getSlotTime(self.slotDay[0].id)
//                }
                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.slotDay.count
    }

    


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotDateCell", for: indexPath) as! SlotDateCell
        
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaBangkok, locale: Locales.thai)
        let date = self.slotDay[indexPath.row].id?.toDate(region: region)
        let day : Int = date!.day
        cell.dayLabel.text = String(day)
        cell.monthLabel.text = date?.monthName(.short)
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
