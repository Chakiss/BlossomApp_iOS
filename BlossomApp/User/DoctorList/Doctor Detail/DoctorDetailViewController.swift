//
//  DoctorDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import UIKit
import Firebase
import FirebaseStorage
import GSImageViewerController

class DoctorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var doctor: Doctor?
    var reviewList: [Reviews] = []
    var filterdReviews: [Reviews] = []
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var backgroundHeaderView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var doctorNickNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorCurrentScoreLabel: UILabel!
    @IBOutlet weak var doctorReviewNumberLabel: UILabel!
    
    @IBOutlet weak var consultButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = doctor?.displayName
        
        backgroundHeaderView.addShadow()
        headerView.addConerRadiusAndShadow()
        self.doctorImageView.layer.cornerRadius = self.doctorImageView.bounds.height/2
        self.consultButton.layer.cornerRadius = 22
        
        let imageRef = storage.reference(withPath: doctor?.displayPhoto ?? "")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.doctorImageView.image = img
                    }
                }
            } else {
                self.doctorImageView.image = UIImage(named: "placeholder")
                
            }
        }
        self.doctorNickNameLabel.text = doctor?.displayName
        self.doctorNameLabel.text = (doctor?.firstName ?? "") + "  " + (doctor?.lastName ?? "")
        let score = (doctor?.score)! as Double
        self.doctorCurrentScoreLabel.text = String(format:"%.2f",score)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.doctorImageView.addGestureRecognizer(tap)
        self.doctorImageView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getReviewsData()

        if let review = doctor?.review, let appointment = doctor?.appointment {
            self.doctorReviewNumberLabel.text = "\(review) รีวิว  รักษา \(appointment) ครั้ง"
        }
        
        self.tableView.reloadData()
        
    }
    
    func getReviewsData(){

        db.collection("reviews")
            .whereField("doctorReference",isEqualTo: doctor?.documentReference)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                
            guard let self = self, let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
                
            self.reviewList = documents.map { queryDocumentSnapshot -> Reviews in
                let data = queryDocumentSnapshot.data()

                let id = queryDocumentSnapshot.documentID
                let appointmentReference = data["appointmentReference"] as? DocumentReference
                let message = data["message"] as? String ?? ""
                let createdAt = data["createdAt"] as? String ?? ""
                let doctorReference = data["doctorReference"] as! DocumentReference
                let score = data["score"] as? Int ?? 0
                let type = data["type"] as? String ?? ""
                let updatedAt = data["updatedAt"] as? String ?? ""
                let patientReference = data["patientReference"] as? DocumentReference

                return Reviews(id: id, appointmentReference: appointmentReference, message: message, createdAt: createdAt, doctorReference: doctorReference, score: score, type: type, updatedAt: updatedAt, patientReference: patientReference)
                
            }
                
                let reviewNumber = self.reviewList.count
                self.doctorReviewNumberLabel.text = "\(reviewNumber) รีวิว"
                self.tableView.reloadData()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
        let imageInfo   = GSImageInfo(image: self.doctorImageView.image!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: self.doctorImageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }
    
    @IBAction func consultButtonTapped() {
        
        guard CustomerManager.sharedInstance.customer != nil else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        guard (CustomerManager.sharedInstance.customer?.acneType?.count ?? 0 > 0 || CustomerManager.sharedInstance.customer?.skinType?.count ?? 0 > 0) else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณากรอกข้อมูลสุขภาพให้ครบถ้วน") { [weak self] in
                self?.showProfile()
            }
            return
        }
        
        guard (CustomerManager.sharedInstance.customer?.isPhoneVerified == true) else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณายืนยันเบอร์โทรศัพท์") { [weak self] in
                self?.showProfile()
            }
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SlotTimeViewController") as! SlotTimeViewController
        viewController.doctor = doctor
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorProfileCell", for: indexPath) as! DoctorProfileCell
            cell.profileLabel.text = doctor?.story
            return cell
        }
        
        let review = self.reviewList[indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        var score = review.score! as Int
        cell.scoreLabel.text = "\(score)"
        cell.commentLabel.text = review.message
        cell.dateLabel.text = review.createdAt
        
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }


}
