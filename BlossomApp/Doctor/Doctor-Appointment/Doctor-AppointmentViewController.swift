//
//  Doctor-AppointmentViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 26/7/2564 BE.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class Doctor_AppointmentViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    
    var customer: Customer?
    var appointments: [Appointment] = []
    var doctor: Doctor?
    var shouldHandleDeeplink: Bool = false
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private lazy var doctorComingAppointmentViewController: Doctor_ComingAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Doctor", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "Doctor_ComingAppointmentViewController") as! Doctor_ComingAppointmentViewController
        return viewController
    }()

    private lazy var historyAppointmentViewController: Doctor_HistoryAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Doctor", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "Doctor_HistoryAppointmentViewController") as! Doctor_HistoryAppointmentViewController
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        if Defaults[\.role] == "doctor" {
            getDoctor()
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    private func setupView() {
        
        add(asChildViewController: doctorComingAppointmentViewController)
        setupSegmentedControl()
        
    
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "การนัดหมาย", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "ประวัติ", at: 1, animated: false)

        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)

        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: historyAppointmentViewController)
            
            add(asChildViewController: doctorComingAppointmentViewController)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            
            remove(asChildViewController: doctorComingAppointmentViewController)
            add(asChildViewController: historyAppointmentViewController)
        } 
    }
    
    func getDoctor(){
        db.collection("doctors").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            self.doctor = snapshot?.data().map({ documentData -> Doctor in
                print(documentData)
                let id = snapshot?.documentID ?? ""
                let createdAt = documentData["createdAt"] as? String ?? ""
                let story = documentData["story"] as? String ?? ""
                let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                let firstName = documentData["firstName"] as? String ?? ""
                let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                let updatedAt = documentData["updatedAt"] as? String ?? ""
                let displayName = documentData["displayName"] as? String ?? ""
                let email = documentData["email"] as? String ?? ""
                let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? UInt ?? 0
                let lastName = documentData["lastName"] as? String ?? ""
                let score = documentData["score"] as? Double ?? 0.0
                let reference = snapshot?.reference
                
                return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto,score: score,documentReference: reference!)
            })
            
            self.getAppointmentData()
        }
    }
    
    func getAppointmentData(){
        
        db.collection("appointments")
            .whereField("doctorReference", isEqualTo: self.doctor?.documentReference as Any)
            .addSnapshotListener { snapshot, error in
                guard let appointments = (snapshot?.documents.map { queryDocumentSnapshot -> Appointment  in
                    let data = queryDocumentSnapshot.data()
                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
                    let timeRef = data["timeReference"]  as? DocumentReference ?? nil
                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
                    let sessionStart = data["sessionStart"] as! Timestamp
                    let sessionEnd = data["sessionEnd"]  as! Timestamp
                    let isComplete = data["isCompleted"]  as! Bool
                    let preForm = data["preForm"] as? [String:Any] ?? ["":""]
                    let postForm = data["postForm"] as? [String:Any] ?? ["":""]
                    let attacheImage = data["attachedImages"] as? [String] ?? []
                    
                    var appointment = Appointment(id: queryDocumentSnapshot.documentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm)
                    appointment.isComplete = isComplete
                    appointment.attachedImages = attacheImage
                    return appointment
                }) else {
                    return
                }
                
                self.appointments = appointments
                
                var inCompleteAppointment: [Appointment] = []
                var completeAppointment: [Appointment] = []
                
                for appointment in self.appointments {
                    if appointment.isComplete == false {
                        inCompleteAppointment.append(appointment)
                    } else {
                        completeAppointment.append(appointment)
                    }
                 }
                inCompleteAppointment.sort(by: { ($0.sessionStart ?? Timestamp()).compare($1.sessionStart ?? Timestamp()) == ComparisonResult.orderedAscending })
                completeAppointment.sort(by: { ($0.sessionStart ?? Timestamp()).compare($1.sessionStart ?? Timestamp()) == ComparisonResult.orderedAscending })
                self.doctorComingAppointmentViewController.appointments = inCompleteAppointment
                self.doctorComingAppointmentViewController.tableView.reloadData()
                
                self.historyAppointmentViewController.appointments = completeAppointment
                //self.doctorComingAppointmentViewController.tableView.reloadData()
            }

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    
    
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        containerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
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

extension Doctor_AppointmentViewController: DeeplinkingHandler {
    
    func handleDeeplink() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deeplinking = appDelegate.deeplinking {
            switch deeplinking {
            case .appointment:
                debugPrint("go to appointment")
                segmentedControl.selectedSegmentIndex = 0
                selectionDidChange(segmentedControl)
            case .appointmentHistory:
                debugPrint("go to appointment history")
                segmentedControl.selectedSegmentIndex = 1
                selectionDidChange(segmentedControl)
            default:
                break
            }
        }
    }

}
