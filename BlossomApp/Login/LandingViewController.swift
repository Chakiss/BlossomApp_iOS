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
        landing1.image = "https://firebasestorage.googleapis.com/v0/b/blossom-clinic-thailand.appspot.com/o/Landing%2FLanding1.png?alt=media&token=77956518-3c74-4f37-8ef9-777d98b1e25b"
        multiBannerView.delegate = self
        multiBannerView.objects = [landing1,landing1,landing1]
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
