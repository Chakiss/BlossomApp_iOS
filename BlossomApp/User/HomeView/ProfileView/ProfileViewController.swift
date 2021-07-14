//
//  ProfileViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    lazy var functions = Functions.functions()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var barButton:UIBarButtonItem = UIBarButtonItem()

    private lazy var profileInformationViewController: ProfileInformationViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ProfileInformationViewController") as! ProfileInformationViewController

        // Add View Controller as Child View Controller
        //self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var profileHealthViewController: ProfileHealthViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ProfileHealthViewController") as! ProfileHealthViewController

        // Add View Controller as Child View Controller
        //self.add(asChildViewController: viewController)

        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"

        setupView()
        
        barButton = UIBarButtonItem(title: "บันทึก", style: .plain, target: self, action: Selector(("saveUserData")))
        
        barButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "SukhumvitSet-Bold", size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
        ], for: .normal)
        barButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "SukhumvitSet-Bold", size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor(white: 1.0, alpha: 0.3),
        ], for: .disabled)
        
        barButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.profileChanged), name:Notification.Name("BlossomProfileChanged"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if barButton.isEnabled == true {
            let alert = UIAlertController(title: "โปรไฟล์มีการแก้ไข", message: "คุณค้องการแก้ไขโปรไฟล์หรือไม่​ ?",         preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in
                //Cancel Action
            }))
            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(_: UIAlertAction!) in
                self.saveUserData()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func saveUserData(){
        
        
        let payload = ["birthDate": profileInformationViewController.birthDayTextField.text!,
                       "firstName": profileInformationViewController.nameTextField.text!,
                       "lastName": profileInformationViewController.surNameTextField.text!,
                       "gender": profileInformationViewController.genderString,
                       "address": profileInformationViewController.addressTextField.text!,
                       "provinceID": "",
                       "districtID": "",
                       "subDistrictID": "",
                       "zipcodeID": ""]
        
        functions.httpsCallable("app-users-updateProfile").call(payload) { result, error in
            
        }
         
    }
    
    @objc private func profileChanged(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        barButton.isEnabled = true
    }
    private func setupView() {
        add(asChildViewController: profileInformationViewController)
        setupSegmentedControl()
        
        let user = Auth.auth().currentUser
        self.nameLabel.text = user?.displayName
        
        
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "ข้อมูลส่วนตัว", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "ข้อมูลสุขภาพ", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)

        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: profileHealthViewController)
            add(asChildViewController: profileInformationViewController)
        } else {
            remove(asChildViewController: profileInformationViewController)
            add(asChildViewController: profileHealthViewController)
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
    

}
