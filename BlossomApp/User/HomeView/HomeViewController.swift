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
import SwiftDate

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
    
    var promotions: [Promotion] = []
    
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
                
        
        getPromotion()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        multiBannerView.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appointmentTapped(tapGestureRecognizer:)))
        appointmentView.isUserInteractionEnabled = true
        appointmentView.addGestureRecognizer(tapGestureRecognizer)
        appointmentView.isHidden = true
        
        doctorAppointmentView.addConerRadiusAndShadow()
        user = Auth.auth().currentUser
        getCustomer()
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
        
        CustomerManager.sharedInstance.getCustomer { [weak self] in
            
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            
            self?.customer = customer            
            self?.getAppointmentData()
            
        }
        
    }
    
    func getAppointmentData(){
        
        db.collection("appointments")
            .whereField("customerReference", isEqualTo: customer?.documentReference as Any)
            .whereField("isCompleted", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                let appointments = (snapshot?.documents.map { queryDocumentSnapshot -> Appointment  in
                    let data = queryDocumentSnapshot.data()
                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
                    let timeRef = data["timeReference"]  as? DocumentReference ?? nil
                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
                    let sessionStart = data["sessionStart"] as! Timestamp
                    let sessionEnd = data["sessionEnd"]  as! Timestamp
                    
                    return Appointment(id: "", customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd)
                })
                
                guard appointments != nil else {
                    return
                }
               
                self?.appointments = appointments!

                if let count = self?.appointments.count, count > 0 {
                    self?.displayAppointment()
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
                    let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? UInt ?? 0
                    let story = data?["story"] as? String ?? ""
                    let createdAt = data?["createdAt"] as? String ?? ""
                    let updatedAt = data?["updatedAt"] as? String ?? ""
                    let displayPhoto = data?["displayPhoto"] as? String ?? ""
                    let currentScore = data?["currentScore"] as? Double ?? 0
                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, currentScore: currentScore,documentReference: document.reference)
                }
                
            
                let region = Region(calendar: Calendars.buddhist, zone: Zones.asiaBangkok, locale: Locales.thai)
                let startDate = DateInRegion((appointment.sessionStart?.dateValue())!, region: region)
                let endDate = DateInRegion((appointment.sessionEnd?.dateValue())!, region: region)
                
                self.dateTimeLabel.text = String(format: "วันที่ %2d %@ %d เวลา %.2d:%.2d - %.2d:%.2d",startDate.day,startDate.monthName(.default),startDate.year,startDate.hour,startDate.minute,endDate.hour,endDate.minute)
                
                
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
    
    func getPromotion() {
        db.collection("promotion")
            .getDocuments { snapshot, error in
                self.promotions =  snapshot?.documents.map { document -> Promotion in
    
                    let data = document.data()
                    let promotion = Promotion()
                    promotion.description = data["description"] as! String
                    promotion.image = data["image"] as! String
                    promotion.termcon = data["termcon"] as! String
                    promotion.link = data["deeplink"] as! String
                   
                    return promotion
                    
                } ?? []
                
                self.multiBannerView.objects = self.promotions
                self.multiBannerView.reload()
            }
        
        
    }
    // MARK: - Action on Promotion
    
    func openCampaign(promotion: Promotion) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "PromotionViewController") as! PromotionViewController
//        viewController.promotion = promotion
//        viewController.modalPresentationStyle = .fullScreen
//        viewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(viewController, animated: true)

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
   
    @IBAction func openReview() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "BlossomReviewViewController") as! BlossomReviewViewController
        viewController.modalPresentationStyle = .fullScreen
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
       
    }
    
    // MARK: - Profile Button Action
    
    @objc func profileButtonTapped() {
        
        if (user == nil) {
            showLoginView()
        } else {
            print("Log in already")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }

    }
    
}
