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
    @IBOutlet weak var doctorProfileImageView: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var doctorNickNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorAppointmentView: UIView!
    
    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var customer:Customer?
    
    var appointments: [Appointment] = []
    
    
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appointmentTapped(tapGestureRecognizer:)))
        appointmentView.isUserInteractionEnabled = true
        appointmentView.addGestureRecognizer(tapGestureRecognizer)
        appointmentView.isHidden = true
        
        doctorAppointmentView.addConerRadiusAndShadow()
        
        user = Auth.auth().currentUser
        getCustomer()
        let projectId = "blossom-clinic-thailand"
        user?.getIDToken(completion: { token, error in
            Request.logIn(withFirebaseProjectID: projectId, accessToken: token!, successBlock: { (user) in
                print(user)
            }) { (error) in
                print(error)
            }
        })
      

//
//        Chat.instance.connect(withUserID: 4554340, password: "123456") { (error) in
//
//        }
    }
    
    @objc func appointmentTapped(tapGestureRecognizer: UITapGestureRecognizer){
      
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .appointment
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
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
        
        
        db.collection("appointments")
            .whereField("customerReference", isEqualTo: customer?.documentReference as Any)
            .whereField("isCompleted", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                self.appointments = (snapshot?.documents.map { queryDocumentSnapshot -> Appointment  in
                    let data = queryDocumentSnapshot.data()
                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
                    let timeRef = data["timeReference"]  as? DocumentReference ?? nil
                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
                    let sessionStart = data["sessionStart"] as! Timestamp
                    let sessionEnd = data["sessionEnd"]  as! Timestamp
                    
                    return Appointment(id: "", customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd)
                })!
               
                if self.appointments.count > 0 {
                    self.displayAppointment()
                }
            }
    }

    func displayAppointment() {
        self.appointmentView.isHidden = false
        let appointment = self.appointments[0]
        db.collection("doctors")
            .document(appointment.doctorReference!.documentID)
            .addSnapshotListener { snapshot, error in
               let doctor =  snapshot.map { document -> Doctor in
                    let data = document.data()
                    let id = document.documentID
                    let firstName = data?["firstName"] as? String ?? ""
                    let displayName = data?["displayName"] as? String ?? ""
                    let email = data?["email"] as? String ?? ""
                    let lastName = data?["lastName"] as? String ?? ""
                    let phoneNumber = data?["phoneNumber"] as? String ?? ""
                    let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? String ?? ""
                    let story = data?["story"] as? String ?? ""
                    let createdAt = data?["createdAt"] as? String ?? ""
                    let updatedAt = data?["updatedAt"] as? String ?? ""
                    let displayPhoto = data?["displayPhoto"] as? String ?? ""
                    let currentScore = data?["currentScore"] as? Double ?? 0
                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, currentScore: currentScore,documentReference: document.reference)
                }
                
            
                self.dateTimeLabel.text = "วันที่ 24 กรกฏาคม 2654 11:00 - 11:30"
                
                self.doctorProfileImageView.layer.cornerRadius = self.doctorProfileImageView.frame.size.width/2
                self.doctorNickNameLabel.text = doctor?.displayName
                self.doctorNameLabel.text = (doctor?.firstName ?? "") + "  " + (doctor?.lastName ?? "")
                let imageRef = self.storage.reference(withPath: doctor?.displayPhoto ?? "")
                imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                    if error == nil {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.doctorProfileImageView.image = img
                            }
                        }
                    } else {
                        self.doctorProfileImageView.image = UIImage(named: "placeholder")
                        
                    }
                }
                
                
                
            }

        
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
