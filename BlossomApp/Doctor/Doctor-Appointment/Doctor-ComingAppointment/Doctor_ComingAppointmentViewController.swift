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
import SwiftyUserDefaults

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
        
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(appointments)
        return appointments.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        cell.appointment = self.appointments[indexPath.row]
        cell.displayCustomer()
         
         return cell
     }

    func attemptCall(with type: CallConferenceType, appointment: Appointment) {
        
        var opponentID = NSNumber(integerLiteral: 0)
        appointment.customerReference?.getDocument(completion: { snapshot, error in
            let snapshotData = snapshot?.data()
            let connectyCubeID = snapshotData?["referenceConnectyCubeID"] as? String ?? ""
            let myInteger = Int(connectyCubeID)
            opponentID = NSNumber(value:myInteger ?? 0)
            
            let opponentIDs: [NSNumber] = [ opponentID]
            CallManager.manager.createSession(with: type, opponentIDs: opponentIDs)

            let name =  "คุณหมอ " + (self.doctor?.firstName ?? "")
            let pushmessage =  "\(name) is calling you."

            let event = Event()
            event.notificationType = .push
            event.usersIDs = opponentIDs
            event.type = .oneShot
            
            var pushParameters = [String : String]()
            pushParameters["message"] = pushmessage

            if let jsonData = try? JSONSerialization.data(withJSONObject: pushParameters,
                                                        options: .prettyPrinted) {
              let jsonString = String(bytes: jsonData,
                                      encoding: String.Encoding.utf8)

              event.message = jsonString

              Request.createEvent(event, successBlock: {(events) in
                
              }, errorBlock: {(error) in

              })
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.callInfo = CallKitAdapter.UserInfo(
                callerName: name,
                doctorDocID: appointment.doctorReference?.documentID ?? "",
                customerDocID: appointment.customerReference?.documentID ?? "",
                startTimestamp: appointment.sessionStart?.seconds ?? 0,
                endTimestamp: appointment.sessionEnd?.seconds ?? 0,
                appointmentID: appointment.id ?? ""
            )
            viewController.hidesBottomBarWhenPushed = true
            viewController.modalPresentationStyle = .fullScreen
            viewController.delegate = self
            self.navigationController?.present(viewController, animated: true, completion: nil)
        })
         
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appointment = self.appointments[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
    
        let alert = UIAlertController(title: "ปรึกษาแพทย์", message: "กรุณาเลือกช่องทางการปรึกษาแพทย์", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "วีดิโอคอล", style: .default , handler:{ [weak self] (UIAlertAction)in
            print("User click Approve button")
            
            
            self?.attemptCall(with: .video, appointment: appointment)

        }))
    
        alert.addAction(UIAlertAction(title: "แชท", style: .default , handler:{ (UIAlertAction)in
            
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
        
        alert.addAction(UIAlertAction(title: "สั่งยา", style: .default , handler:{ [weak self] (UIAlertAction) in
            
            ProgressHUD.show()
            CustomerManager.sharedInstance.getCustomerData(uid: appointment.customerReference?.documentID ?? "") { [weak self] customerData in
                
                ProgressHUD.dismiss()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
                viewController.customer = customerData
                viewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(viewController, animated: true)

            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "รายละเอียด", style: .default, handler: { [weak self] (UIAlertAction) in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HistoryAppointmentDetailViewController") as! HistoryAppointmentDetailViewController
            viewController.appointment = appointment
            viewController.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(viewController, animated: true)
            
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
        
        
    }

}

extension Doctor_ComingAppointmentViewController: CallViewControllerDelegate {
    
    func callViewDidEndCall(info: CallKitAdapter.UserInfo) {
        CallManager.manager.handleDidEndCall(info: info, controller: self.navigationController)
    }
    
}
