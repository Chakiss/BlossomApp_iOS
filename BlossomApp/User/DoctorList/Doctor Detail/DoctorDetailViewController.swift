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
        self.doctorCurrentScoreLabel.text = String(format: "%.2f",doctor?.currentScore as! CVarArg)
        self.doctorReviewNumberLabel.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fieldDoctpr = "doctors/" + (self.doctor?.id)!
        db.collection("reviews").whereField("doctorReference", isEqualTo: fieldDoctpr)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    print(querySnapshot)
                    print("xxxxxxx")
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
    }
    
    @IBAction func consultButtonTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SlotTimeViewController") as! SlotTimeViewController
        viewController.doctor = doctor
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            cell.textLabel?.text = "Header"
            return cell
        }
        let doctor = self.reviewList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorCell
        
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//
//        let doctor = self.doctorList[indexPath.row]
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "DoctorDetailViewController") as! DoctorDetailViewController
//        viewController.doctor = doctor
//        viewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(viewController, animated: true)
    }


}
