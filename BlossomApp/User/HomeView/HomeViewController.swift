//
//  HomeViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import Foundation
import UIKit

import Firebase


class HomeViewController: UIViewController, MultiBannerViewDelegate {
   
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var multiBannerView: MultiBannerView!
    
    @IBOutlet weak var appointmentView: UIView!
    @IBOutlet weak var doctorAppointmentView: UIView!
    
    var user: User!

    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "หน้าแรก"

        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "user"), for: .normal)
        button.addTarget(self, action: #selector(self.profileButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
                
        
        doctorAppointmentView.addConerRadiusAndShadow()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        multiBannerView.delegate = self
        multiBannerView.objects = [Promotion(),Promotion(),Promotion()]
        multiBannerView.reload()
        
        user = Auth.auth().currentUser
      
    }
    // MARK: - Action on Promotion
    
    func openCampaign(promotion: Promotion) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PromotionViewController") as! PromotionViewController
        viewController.promotion = promotion
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
   
    
    // MARK: - Profile Button Action
    
    @objc func profileButtonTapped() {
        
        if (user == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
           
            let regsterNavigationController = UINavigationController(rootViewController: viewController)
            regsterNavigationController.modalPresentationStyle = .fullScreen
            regsterNavigationController.navigationBar.tintColor = UIColor.white
            self.navigationController?.present(regsterNavigationController, animated: true, completion:nil)
            
        } else {
            print("Log in already")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }

    }
    
}
