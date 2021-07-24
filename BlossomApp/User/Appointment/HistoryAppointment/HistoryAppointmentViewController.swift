//
//  HistoryAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit

class HistoryAppointmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var appointments: [Appointment] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let doctor = self.doctorList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
//         cell.doctorNickNameLabel.text = doctor.displayName
//         cell.doctorNameLabel.text = (doctor.firstName ?? "") + "  " + (doctor.lastName ?? "")
//
//
//         let imageRef = storage.reference(withPath: doctor.displayPhoto ?? "")
//         imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
//             if error == nil {
//                 if let imgData = data {
//                     if let img = UIImage(data: imgData) {
//                         cell.doctorImageView.image = img
//                     }
//                 }
//             } else {
//                 cell.doctorImageView.image = UIImage(named: "placeholder")
//
//             }
//         }
//
//         cell.doctorStarLabel.text = String(format: "%.2f",doctor.currentScore as! CVarArg)
//         cell.doctorReviewLabel.text = ""
//         cell.calculateReview(reviews: reviewList)
        
        return cell
    }

   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
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
