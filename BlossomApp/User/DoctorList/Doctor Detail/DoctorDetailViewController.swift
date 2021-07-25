//
//  DoctorDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import UIKit
import Firebase
import FirebaseStorage

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
        let score = (doctor?.currentScore)! as Double
        self.doctorCurrentScoreLabel.text = "\(score)"
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        for review in self.reviewList {
            if review.doctorReference == doctor?.documentReference {
                filterdReviews.append(review)
            }
        }
        let reviewNumber = filterdReviews.count as Int
        self.doctorReviewNumberLabel.text = "\(reviewNumber) รีวิว"
        self.tableView.reloadData()
        
    }
    
    @IBAction func consultButtonTapped() {
        
        guard CustomerManager.sharedInstance.customer != nil else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SlotTimeViewController") as! SlotTimeViewController
        viewController.doctor = doctor
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdReviews.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorProfileCell", for: indexPath) as! DoctorProfileCell
            cell.profileLabel.text = doctor?.story
            return cell
        }
        
        let review = self.filterdReviews[indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        var score = review.score! as Int
        cell.scoreLabel.text = "\(score)"
        cell.commentLabel.text = review.comment
        cell.dateLabel.text = review.createdAt
        
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }


}
