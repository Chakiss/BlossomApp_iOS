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
    
    @IBOutlet weak var medicineView: UIView!
    
    @IBOutlet weak var productButton1: UIButton!
    @IBOutlet weak var productButton2: UIButton!
    @IBOutlet weak var productButton3: UIButton!
    
    @IBOutlet weak var productDetailButton: UIButton!
    
    @IBOutlet weak var reviewImageView: UIImageView!
    
    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var customer:Customer?
    
    var appointments: [Appointment] = []
    
    var promotions: [Promotion] = []
    
    var productHilights: [ProductHilight] = []
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var profileButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "หน้าแรก"

        profileButton = UIButton(type: UIButton.ButtonType.custom)
        profileButton.setImage(UIImage(named: "user"), for: .normal)
        profileButton.addTarget(self, action: #selector(self.profileButtonTapped), for: .touchUpInside)
        profileButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: profileButton)
        self.navigationItem.leftBarButtonItem = barButton
                
        
        getPromotion()
        getProduct_Hilight()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        multiBannerView.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appointmentTapped(tapGestureRecognizer:)))
        appointmentView.isUserInteractionEnabled = true
        appointmentView.addGestureRecognizer(tapGestureRecognizer)
        appointmentView.isHidden = true
        
        medicineView.isHidden = true
        
        let reviewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openReview(tapGestureRecognizer:)))
        reviewImageView.isUserInteractionEnabled = true
        reviewImageView.addGestureRecognizer(reviewGestureRecognizer)
        
        
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
    
    func displayUserProfileImage(){
        let imageRef = self.storage.reference(withPath: self.customer?.displayPhoto ?? "")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        
                        
                        self.profileButton.setImage(img, for: .normal)
                        self.profileButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                        self.profileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        self.profileButton.imageView?.layer.cornerRadius = 15
                        let barButton = UIBarButtonItem(customView: self.profileButton ?? UIButton())
                        self.navigationItem.leftBarButtonItem = barButton
                    }
                }
            }
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
        self.displayUserProfileImage()
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
                    let preForm = data["preForm"] as? [String:Any] ?? ["":""]
                    let postForm = data["postForm"] as? [String:Any] ?? ["":""]
                    
                    let appointment = Appointment(id: queryDocumentSnapshot.documentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm)
                    return appointment
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
                    let score = data?["score"] as? Double ?? 0
                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, score: score,documentReference: document.reference)
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
                self.promotions.sort { $0.image < $1.image }
                
                self.multiBannerView.objects = self.promotions
                self.multiBannerView.reload()
            }
        
        
    }
    
    func getProduct_Hilight() {
        db.collection("product_hilight")
            .getDocuments { snapshot, error in
                self.productHilights =  snapshot?.documents.map { document -> ProductHilight in
    
                    let data = document.data()
                    let productHilight = ProductHilight()
                    
                    productHilight.image = data["image"] as! String
                    productHilight.deeplink = data["deeplink"] as! String
                    productHilight.code = data["code"] as! String
                   
                    return productHilight
                    
                } ?? []
                
                if self.productHilights.count == 3 {
                    if let imgURL = URL(string: self.productHilights[0].image) {
                        self.productButton1.kf.setImage(with: imgURL, for: .normal)
                        self.productButton1.tag = 0
                        self.productButton1.addTarget(self, action: #selector(self.openProductHilight), for: .touchUpInside)
                    }
                    if let imgURL = URL(string: self.productHilights[1].image) {
                        self.productButton2.kf.setImage(with: imgURL, for: .normal)
                        self.productButton2.tag = 1
                        self.productButton2.addTarget(self, action: #selector(self.openProductHilight), for: .touchUpInside)
                    }
                    if let imgURL = URL(string: self.productHilights[2].image) {
                        self.productButton3.kf.setImage(with: imgURL, for: .normal)
                        self.productButton3.tag = 2
                        self.productButton3.addTarget(self, action: #selector(self.openProductHilight), for: .touchUpInside)
                    }
                    
                    
                }
                
            }
        
        
    }
    
    @IBAction func openDoctor(_ sender: UITapGestureRecognizer) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate.deeplinking = .doctor
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
        }
    }
    
    
    @IBAction func openProduct() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate.deeplinking = .product(id: "")
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
        }
    }
    @IBAction func openProductHilight(id: UIButton) {
       
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {

            appDelegate.deeplinking = .product(id: self.productHilights[id.tag].code)
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
        }
    }
    // MARK: - Action on Promotion
    
    func openCampaign(promotion: Promotion) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PromotionViewController") as! PromotionViewController
        viewController.promotion = promotion
        viewController.modalPresentationStyle = .fullScreen
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)

        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
//        viewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
   
    @objc func openReview(tapGestureRecognizer: UITapGestureRecognizer) {
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
