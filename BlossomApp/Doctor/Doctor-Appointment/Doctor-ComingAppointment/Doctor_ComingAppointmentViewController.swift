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
            
            
            self.attemptCall(with: .video)

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
        
        
    }
    
    
    
    func attemptCall(with type: CallConferenceType) {
        
        let opponentIDs: [NSNumber] = [ 4554340]
        CallManager.manager.createSession(with: type, opponentIDs: opponentIDs)

     
            let payload = [
                "message" : String(format: "xxxxxx is calling you."),
                "ios_voip" : "1",
                "VOIPCall" : "1",
            ]
            let data = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            let message = String(data: data, encoding: String.Encoding.utf8)

            let event = Event()
            event.notificationType = .push
            event.usersIDs = opponentIDs
            event.type = .oneShot
            
            var pushmessage =  "xxxxxx is calling you."
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
//            session.startCall(["key":"value"])
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            viewController.hidesBottomBarWhenPushed = true
        viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
//        }
         
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
