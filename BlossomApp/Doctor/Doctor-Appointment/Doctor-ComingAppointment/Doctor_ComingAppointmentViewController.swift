//
//  Doctor_ComingAppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 26/7/2564 BE.
//

import UIKit
import Firebase
import ConnectyCube
import ConnectyCubeCalls

class Doctor_ComingAppointmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
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
        let cell = tableView.cellForRow(at: indexPath)
        let alert = UIAlertController(title: "ปรึกษาแพทย์", message: "กรุณาเลือกช่องทางการปรึกษาแพทย์", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "วีดิโอคอล", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            
            
            //self.attemptCall(with: .video)

        }))
    
        alert.addAction(UIAlertAction(title: "แชท", style: .default , handler:{ (UIAlertAction)in
            
            let appointment = self.appointments[indexPath.row]
            appointment.customerReference?.getDocument(completion: { doctorDocument, error in
                
                let data = doctorDocument?.data()
                let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? String ?? ""
                if let connectyCubeID = Int(referenceConnectyCubeID) {
                    let numberConnectyCubeID = NSNumber(value:connectyCubeID)
                    
                    let dialog = ChatDialog(dialogID: nil, type: .private)
                    
                    dialog.occupantIDs = [numberConnectyCubeID]  // an ID of opponent

                    Request.createDialog(dialog, successBlock: { (dialog) in
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.deeplinking = .chat
                            appDelegate.handleDeeplinking()
                            self.dismiss(animated: false, completion: {
                                self.navigationController?.popToRootViewController(animated: false)
                            })
                        }
                    }) { (error) in
                        print(error)
                     }
                }
                
                
            })
           
        }))
        
        alert.addAction(UIAlertAction(title: "สั่งยา", style: .default , handler:{ (UIAlertAction) in
            
        }))
        
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .destructive, handler:{ (UIAlertAction) in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = cell?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0);
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        //         let doctor = self.doctorList[indexPath.row]
        
       
        
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
