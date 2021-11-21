//
//  AllAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 5/8/2564 BE.
//

import UIKit
import Firebase
import SwiftDate

class AllAppointmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

    var customerReference: DocumentReference?
    var appointments: [Appointment] = []
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppointment()
        CustomerManager.sharedInstance.getCustomerData(uid: customerReference?.documentID ?? "") { customer in
            self.title = customer?.displayName
        }
        
        // Do any additional setup after loading the view.
    }
    
    func getAppointment(){
        
        db.collection("appointments")
            .whereField("customerReference", isEqualTo: customerReference as Any)
            .addSnapshotListener { snapshot, error in
                self.appointments = (snapshot?.documents.map { queryDocumentSnapshot -> Appointment  in
                    let data = queryDocumentSnapshot.data()
                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
                    let timeRef = data["timeReference"]  as? DocumentReference ?? nil
                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
                    let sessionStart = data["sessionStart"] as! Timestamp
                    let sessionEnd = data["sessionEnd"]  as! Timestamp
                    let isComplete = data["isCompleted"]  as! Bool
                    let preForm = data["preForm"] as? [String:Any] ?? ["":""]
                    let postForm = data["postForm"] as? [String:Any] ?? ["":""]
                    
                    let attachedImages = data["attachedImages"] as? [String] ?? []
                    let createdAt = data["createdAt"] as! Timestamp
                    let updatedAt = data["updatedAt"]  as! Timestamp
                    
                    var appointment = Appointment(id: queryDocumentSnapshot.documentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm, createdAt: createdAt, updatedAt: updatedAt)
                    
                    appointment.isComplete = isComplete
                    appointment.attachedImages = attachedImages
                    return appointment
                }) ?? []
               
                self.appointments.sort(by: { ($0.sessionStart ?? Timestamp()).compare($1.sessionStart ?? Timestamp()) == ComparisonResult.orderedDescending })
                self.tableView.reloadData()
                

            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appointment = self.appointments[indexPath.row]
            
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: " ")
        
        let region = Region(calendar: Calendars.buddhist, zone: Zones.asiaBangkok, locale: Locales.thai)
        let startDate = DateInRegion((appointment.sessionStart?.dateValue())!, region: region)
        let endDate = DateInRegion((appointment.sessionEnd?.dateValue())!, region: region)
        
        cell.textLabel?.text = String(format: "วันที่ %2d %@ %d เวลา %.2d:%.2d - %.2d:%.2d",startDate.day,startDate.monthName(.default),startDate.year,startDate.hour,startDate.minute,endDate.hour,endDate.minute)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appointment = self.appointments[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HistoryAppointmentDetailViewController") as! HistoryAppointmentDetailViewController
        viewController.appointment = appointment
        viewController.isShowAppointmentButton = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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
