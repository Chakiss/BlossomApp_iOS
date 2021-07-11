//
//  ProfileViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var nameLabel: UILabel!

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
        
        
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "logout"), for: .normal)
        button.addTarget(self, action: #selector(self.logoutButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        
        // Do any additional setup after loading the view.
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
    
    @objc func logoutButtonTapped() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            self.navigationController?.popToRootViewController(animated: true)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
           
            let regsterNavigationController = UINavigationController(rootViewController: viewController)
            regsterNavigationController.modalPresentationStyle = .fullScreen
            regsterNavigationController.navigationBar.tintColor = UIColor.white
            self.navigationController?.present(regsterNavigationController, animated: true, completion:nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
