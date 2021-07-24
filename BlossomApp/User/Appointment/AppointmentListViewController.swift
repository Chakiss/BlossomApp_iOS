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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private lazy var comingAppointmentViewController: ComingAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ComingAppointmentViewController") as! ComingAppointmentViewController
        return viewController
    }()

    private lazy var historyAppointmentViewController: HistoryAppointmentViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "HistoryAppointmentViewController") as! HistoryAppointmentViewController
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
        getAppointmentData()
        // Do any additional setup after loading the view.
    }
    
    private func setupView() {
        
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
            case .appointment:
                debugPrint("go to Appointment list")
            }
            appDelegate.deeplinking = nil
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
    
    func getAppointmentData() {
        //customers/fEdvG7leqyR8BavmGpyx3gWxRln1
        //customerReference
        
        db.collection("appointments")
            //.whereField("customerReference", isEqualTo:  )
            .getDocuments { querySnapshot, error in
       
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            print(documents)
            print("xxxxxx")
//            self.doctorList = documents.map { queryDocumentSnapshot -> Doctor in
//                let data = queryDocumentSnapshot.data()
//
//                let id = queryDocumentSnapshot.documentID
//                let firstName = data["firstName"] as? String ?? ""
//                let displayName = data["displayName"] as? String ?? ""
//                let email = data["email"] as? String ?? ""
//                let lastName = data["lastName"] as? String ?? ""
//                let phoneNumber = data["phoneNumber"] as? String ?? ""
//                let referenceConnectyCubeID = data["referenceConnectyCubeID"] as? String ?? ""
//                let story = data["story"] as? String ?? ""
//                let createdAt = data["createdAt"] as? String ?? ""
//                let updatedAt = data["updatedAt"] as? String ?? ""
//                let displayPhoto = data["displayPhoto"] as? String ?? ""
//                let currentScore = data["currentScore"] as? Double ?? 0
//                return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, currentScore: currentScore)
//
//            }
//            self.tableView.reloadData()
        }
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
