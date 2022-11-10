//
//  DoctorProfileViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import UIKit
import Firebase
import FBSDKLoginKit
import ConnectyCube

class DoctorProfileViewController: UIViewController {

    lazy var functions = Functions.functions()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    
    var doctor: Doctor?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var facebookNameLabel: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    var isLinkFacebook: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Doctor Profile"
        
        setupView()
        // Do any additional setup after loading the view.
    }
    
    private func setupView() {
        
        //add(asChildViewController: profileInformationViewController)
        //setupSegmentedControl()
        
        let user = Auth.auth().currentUser
        self.nameLabel.text = user?.displayName
        
        connectFacebookButton.layer.cornerRadius = 15
        self.profileImageView.circleView()
        self.profileImageView.addShadow()
        
        let imageRef = self.storage.reference().child(doctor?.displayPhoto ?? "")
        let placeholderImage = UIImage(named: "placeholder")
        self.profileImageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        
      
        
        signOutButton.layer.cornerRadius = 22
        
        let userInfoList: [UserInfo] = user?.providerData ?? []
        for userInfo in userInfoList {
            print(userInfo.providerID)
            if userInfo.providerID.contains("facebook") {
                isLinkFacebook = true
            } 
        }
        
        
        checkFacebook()
    }
    
    func checkFacebook() {
        if isLinkFacebook {
            self.connectFacebookButton.setTitle("Unlink", for: .normal)
            self.connectFacebookButton.addTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
            if let accessToken  = AccessToken.current {
                let r = GraphRequest(graphPath: "me",
                                          parameters: ["fields": "email,name"],
                                          tokenString: AccessToken.current!.tokenString,
                                          version: nil,
                                          httpMethod: HTTPMethod.get)

                r.start { test, result, error in
                    if error == nil {
                        guard let json = result as? NSDictionary else { return }
                        self.facebookNameLabel.text = json["name"] as? String ?? ""
                    }
                }
            } else {

                let userInfoList: [UserInfo] = self.user?.providerData ?? []
                for userInfo in userInfoList {
                    if userInfo.providerID.contains("facebook") {
                        Auth.auth().currentUser?.unlink(fromProvider: userInfo.providerID) { user, error in
                            ProgressHUD.dismiss()
                            self.isLinkFacebook = false
                            self.connectFacebookButton.removeTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
                            self.setupView()
                        }
                    }
                }
            }
           
        } else {
            self.facebookNameLabel.text = ""
            self.connectFacebookButton.setTitle("Link", for: .normal)
            self.connectFacebookButton.addTarget(self, action: #selector(self.linkAccountFacebook), for: .touchUpInside)

        }
    }
    
    
    @objc func linkAccountFacebook(){
       
        ProgressHUD.show()
        
        
        let loginManager = LoginManager()
        guard let configuration = LoginConfiguration(
            permissions:["email", "public_profile"],
            tracking: .limited,
            nonce: "123"
        )
        else {
            return
        }

        loginManager.logIn(configuration: configuration) { (loginResult) in
          switch loginResult {
          case .success:
            let credential = FacebookAuthProvider
                .credential(withAccessToken: AccessToken.current!.tokenString)
            self.user?.link(with: credential) { authResult, error in
                ProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "กรุณาตรวจสอบ", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.isLinkFacebook = true
                    self.connectFacebookButton.removeTarget(self, action: #selector(self.linkAccountFacebook), for: .touchUpInside)
                    self.setupView()
                }
            }
            
          case .cancelled:
            ProgressHUD.dismiss()
              print("Login: cancelled.")
          case .failed(let error):
            ProgressHUD.dismiss()
            print("Login with error: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }
        }
    }
    
    @objc func unLinkAccountFacebook() {
        let alert = UIAlertController(title: "โปรไฟล์มีการแก้ไข", message: "คุณค้องการยกเลิกการเชื่อมต่อบัญชีกับ facebook หรือไม่​ ?",         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "ตกลง", style: .destructive, handler: {(_: UIAlertAction!) in
            ProgressHUD.show()
            let userInfoList: [UserInfo] = self.user?.providerData ?? []
            for userInfo in userInfoList {
                if userInfo.providerID.contains("facebook") {
                    Auth.auth().currentUser?.unlink(fromProvider: userInfo.providerID) { user, error in
                        ProgressHUD.dismiss()
                        self.isLinkFacebook = false
                        self.connectFacebookButton.removeTarget(self, action: #selector(self.unLinkAccountFacebook), for: .touchUpInside)
                        self.setupView()
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }


    
    @IBAction func logoutButtonTapped() {
        let alert = UIAlertController(title: "ออกจากระบบ ?", message: "คุณค้องการออกจากระบบหรือไม่​ ?",         preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: {(_: UIAlertAction!) in
            //Sign out action
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                UIApplication.shared.unregisterForRemoteNotifications()

                // Unregister from server
                let deviceIdentifier = UIDevice.current.identifierForVendor!.uuidString
                Request.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: {

                }) { (error) in

                }
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
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
