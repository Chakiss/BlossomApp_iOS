//
//  LandingViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import SwiftyUserDefaults

class LandingViewController: UIViewController,MultiBannerViewDelegate {

    func openCampaign(promotion: Promotion) {

    }

    @IBOutlet weak var multiBannerView: MultiBannerView!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let landing1 = Promotion()
        landing1.image = "https://www.blossomclinicthailand.com/wp-content/uploads/2021/08/app-cover-1.png"
        let landing2 = Promotion()
        landing2.image = "https://www.blossomclinicthailand.com/wp-content/uploads/2021/08/app-cover-2.png"
        let landing3 = Promotion()
        landing3.image = "https://www.blossomclinicthailand.com/wp-content/uploads/2021/08/app-cover-3.png"
        let landing4 = Promotion()
        landing4.image = "https://www.blossomclinicthailand.com/wp-content/uploads/2021/08/app-cover-4.png"
        
        multiBannerView.delegate = self
        multiBannerView.objects = [landing1,landing2,landing3,landing4]
        multiBannerView.reload()
        
        self.registerButton.layer.cornerRadius = 22
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissLogin))
        Defaults[\.role]?.removeAll()
    }
    
    @objc private func dismissLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func loginButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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
