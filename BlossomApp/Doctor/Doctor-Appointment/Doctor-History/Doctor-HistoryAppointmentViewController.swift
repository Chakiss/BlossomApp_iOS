//
//  Doctor-HistoryAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 1/8/2564 BE.
//

import UIKit
import Firebase

class Doctor_HistoryAppointmentViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate  {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    
    var customer: Customer?
    var appointments: [Appointment] = []
    var doctor: Doctor?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let doctor = self.doctorList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
       cell.appointment = self.appointments[indexPath.row]
       cell.displayCustomer()
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appointment = self.appointments[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HistoryAppointmentDetailViewController") as! HistoryAppointmentDetailViewController
        viewController.appointment = appointment
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
