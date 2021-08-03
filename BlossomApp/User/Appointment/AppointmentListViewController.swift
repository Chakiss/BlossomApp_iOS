//
//  AppointmentListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Firebase

class AppointmentListViewController: UIViewController {

    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var customer: Customer?
    var appointments: [Appointment] = []
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private lazy var comingAppointmentViewController: ComingAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ComingAppointmentViewController") as! ComingAppointmentViewController
        viewController.parentVC = self
        return viewController
    }()

    private lazy var historyAppointmentViewController: HistoryAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "HistoryAppointmentViewController") as! HistoryAppointmentViewController
        viewController.parentVC = self
        return viewController
    }()
    
    private lazy var medicineListViewController: MedicineListViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "MedicineListViewController") as! MedicineListViewController
        return viewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ตารางนัดหมาย"
        
        setupView()
        getCustomer()
        // Do any additional setup after loading the view.
    }
    
    func getCustomer()  {
        CustomerManager.sharedInstance.getCustomer { [weak self] in
            
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            
            self?.customer = customer
            self?.getAppointmentData()
        }
        
    }
    private func setupView() {
        
        view.backgroundColor = .backgroundColor
        add(asChildViewController: comingAppointmentViewController)
        setupSegmentedControl()        
    
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "การนัดหมาย", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "ประวัติ", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "ใบสั่งยา", at: 2, animated: false)
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
            remove(asChildViewController: medicineListViewController)
            add(asChildViewController: comingAppointmentViewController)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            remove(asChildViewController: comingAppointmentViewController)
            remove(asChildViewController: medicineListViewController)
            add(asChildViewController: historyAppointmentViewController)
        } else {
            remove(asChildViewController: comingAppointmentViewController)
            remove(asChildViewController: historyAppointmentViewController)
            add(asChildViewController: medicineListViewController)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gotoOrderList()
    }
    
    func gotoOrderList() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deeplinking = appDelegate.deeplinking {
            switch deeplinking {
            case .orderList:
                debugPrint("go to order list")
                segmentedControl.selectedSegmentIndex = 2
                selectionDidChange(segmentedControl)
            default:
                break
            }
        }
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
    
    func getAppointmentData(){
        
        
        db.collection("appointments")
            .whereField("customerReference", isEqualTo: customer?.documentReference as Any)
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
                    
                    var appointment = Appointment(id: queryDocumentSnapshot.documentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm)
                    appointment.isComplete = isComplete
                    appointment.attachedImages = attachedImages
                    return appointment
                }) ?? []
               
                var inCompleteAppointment: [Appointment] = []
                var completeAppointment: [Appointment] = []
                
                for appointment in self.appointments {
                    if appointment.isComplete == false {
                        inCompleteAppointment.append(appointment)
                    } else {
                        completeAppointment.append(appointment)
                    }
                 }
                
                self.comingAppointmentViewController.appointments = inCompleteAppointment
                self.comingAppointmentViewController.tableView.reloadData()
                
                self.historyAppointmentViewController.appointments = completeAppointment
                

            }
    }

    func displayAppointment() {
//
//        db.collection("doctors")
//            .document(appointment.doctorReference!.documentID)
//            .addSnapshotListener { snapshot, error in
//               let doctor =  snapshot.map { document -> Doctor in
//                    let data = document.data()
//                    let id = document.documentID
//                    let firstName = data?["firstName"] as? String ?? ""
//                    let displayName = data?["displayName"] as? String ?? ""
//                    let email = data?["email"] as? String ?? ""
//                    let lastName = data?["lastName"] as? String ?? ""
//                    let phoneNumber = data?["phoneNumber"] as? String ?? ""
//                    let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? String ?? ""
//                    let story = data?["story"] as? String ?? ""
//                    let createdAt = data?["createdAt"] as? String ?? ""
//                    let updatedAt = data?["updatedAt"] as? String ?? ""
//                    let displayPhoto = data?["displayPhoto"] as? String ?? ""
//                    let currentScore = data?["currentScore"] as? Double ?? 0
//                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, currentScore: currentScore,documentReference: document.reference)
//                }
//
//
//                self.dateTimeLabel.text = "วันที่ 24 กรกฏาคม 2654 11:00 - 11:30"
//
//                self.doctorProfileImageView.layer.cornerRadius = self.doctorProfileImageView.frame.size.width/2
//                self.doctorNickNameLabel.text = doctor?.displayName
//                self.doctorNameLabel.text = (doctor?.firstName ?? "") + "  " + (doctor?.lastName ?? "")
//                let imageRef = self.storage.reference(withPath: doctor?.displayPhoto ?? "")
//                imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
//                    if error == nil {
//                        if let imgData = data {
//                            if let img = UIImage(data: imgData) {
//                                self.doctorProfileImageView.image = img
//                            }
//                        }
//                    } else {
//                        self.doctorProfileImageView.image = UIImage(named: "placeholder")
//
//                    }
//                }
//            }
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
