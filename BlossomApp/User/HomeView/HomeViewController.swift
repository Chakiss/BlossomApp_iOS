//
//  HomeViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import Foundation
import UIKit

import Firebase
import ConnectyCube

class HomeViewController: UIViewController, MultiBannerViewDelegate {
   
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var multiBannerView: MultiBannerView!
    
    @IBOutlet weak var appointmentView: UIView!
    @IBOutlet weak var doctorAppointmentView: UIView!
    
    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    var customer:Customer?


    
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
                

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        multiBannerView.objects = [Promotion(),Promotion(),Promotion()]
        multiBannerView.delegate = self
        multiBannerView.reload()
        
        
        doctorAppointmentView.addConerRadiusAndShadow()
        
        user = Auth.auth().currentUser
        
        getCustomer()
        
        Chat.instance.connect(withUserID: 4554340, password: "123456") { (error) in

        }
    }
    
    func getCustomer()  {
        
        guard user != nil else {
            return
        }
        
        db.collection("customers").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            
            self.customer = (snapshot?.data().map({ documentData -> Customer in
                let id = snapshot?.documentID ?? ""
                let createdAt = documentData["createdAt"] as? String ?? ""
                let displayName = documentData["displayName"] as? String ?? ""
                let email = documentData["email"] as? String ?? ""
                let firstName = documentData["firstName"] as? String ?? ""
                let isEmailVerified: Bool = (documentData["isEmailVerified"] ?? false) as! Bool
                let isPhoneVerified: Bool = (documentData["isPhoneVerified"] ?? false) as! Bool
                let lastName = documentData["lastName"] as? String ?? ""
                let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                let platform = documentData["platform"] as? String ?? ""
                let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? String ?? ""
                let referenceShipnityID = documentData["referenceShipnityID"] as? String ?? ""
                let updatedAt = documentData["updatedAt"] as? String ?? ""
                let gender = documentData["gender"] as? String ?? ""
                let birthDateTimestamp = documentData["birthDate"] as? Timestamp
                var birthDay = ""
                var birthDayString = ""
                var birthDayDisplayString = ""
                if let birthDate = birthDateTimestamp?.dateValue() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    birthDayString = dateFormatter.string(from: birthDate)
                    birthDay = dateFormatter.string(from: birthDate)
                    dateFormatter.dateStyle = .medium
                    birthDayDisplayString = dateFormatter.string(from: birthDate)
                }
                
                let tmpAddress = documentData["address"] as? [String : Any] ?? [:]
                var address = Address()
                address.address = tmpAddress["address"] as? String ?? ""
                
                
                let genderString = gender
                
                let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                
                let skinType = documentData["skinType"] as? String ?? ""
                let acneType = documentData["acneType"] as? String ?? ""
                let acneCaredDescription = documentData["acneCaredDescription"] as? String ?? ""
                let allergicDrug = documentData["allergicDrug"] as? String ?? ""
                
                let documentSnapshot = snapshot?.reference
                
                return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt, gender: gender,genderString: genderString, birthDate: birthDay,birthDayDisplayString: birthDayDisplayString, birthDayString: birthDayString, address: address, displayPhoto: displayPhoto,skinType: skinType, acneType: acneType, acneCaredDescription: acneCaredDescription, allergicDrug: allergicDrug,documentReference: documentSnapshot!
                )
                
            }))!
            self.getAppointmentData()
        }
    }
    
    func getAppointmentData(){
        print(customer?.documentReference)
        
        db.collection("appointments").getDocuments { snapshot, error in
           // let appointmnet = (snapshot?.data().map({ documentData -> Customer in
            
            //})
            //if review.doctorReference == customer?.documentReference {
            //   count += 1
           // }
        }
        //db.collection("appointments").whereField("customerReference", isEqualTo: customer?.documentReference).addSnapshotListener { snapshot, error in
          //  print(snapshot)
           // print("xxxxx")
        //}
    }

    // MARK: - Action on Promotion
    
    func openCampaign(promotion: Promotion) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PreFormViewController") as! PreFormViewController
        viewController.modalPresentationStyle = .fullScreen
        //xviewController.hidesBottomBarWhenPushed = true
        //self.navigationController?.pushViewController(viewController, animated: true)
        self.navigationController?.present(viewController, animated: true, completion: nil)
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
