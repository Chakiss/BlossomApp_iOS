//
//  ProfileViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!

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
        
        // Do any additional setup after loading the view.
    }
    
    private func setupView() {
        add(asChildViewController: profileInformationViewController)
        setupSegmentedControl()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
