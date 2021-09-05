//
//  AppointmentListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class AppointmentListViewController: UIViewController {

    var shouldHandleDeeplink = true

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
        
        if shouldHandleDeeplink {
            handleDeeplink()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if Defaults[\.orderList] == "N" {
            
        }
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
        segmentedControl.insertSegment(withTitle: "ใบสั่งผลิตภัณฑ์", at: 2, animated: false)
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
                inCompleteAppointment.sort(by: { ($0.sessionStart ?? Timestamp()).compare($1.sessionStart ?? Timestamp()) == ComparisonResult.orderedAscending })
                
                inCompleteAppointment = inCompleteAppointment.filter({ $0.sessionStart?.dateValue().startOfDay ?? Date().startOfDay >= Date().startOfDay })
                
                self.comingAppointmentViewController.appointments = inCompleteAppointment
                self.comingAppointmentViewController.tableView.reloadData()
                
                self.historyAppointmentViewController.appointments = completeAppointment
                

            }
    }

    func displayAppointment() {

    }
    
  

}

extension AppointmentListViewController: DeeplinkingHandler {
        
    func handleDeeplink() {
                
        guard isViewLoaded else {
            return
        }
        
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
            case .orderList:
                debugPrint("go to order list")
                segmentedControl.selectedSegmentIndex = 2
                selectionDidChange(segmentedControl)
                medicineListViewController.handleDeeplink()
            default:
                break
            }
            appDelegate.deeplinking = nil
            shouldHandleDeeplink = false
        }
    }

    
}
