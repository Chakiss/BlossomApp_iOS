//
//  DoctorListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Firebase
import FirebaseStorage

class DoctorListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var doctorList: [Doctor] = []
    var reviewList: [Reviews] = []
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "แพทย์"
        // Do any additional setup after loading the view.
    
        getDoctorData()
      
        getReviewsData()
    
    }
    
    func getDoctorData() {
        db.collection("doctors").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.doctorList = documents.map { queryDocumentSnapshot -> Doctor in
                let data = queryDocumentSnapshot.data()
                
                
                let id = queryDocumentSnapshot.documentID
                let firstName = data["firstName"] as? String ?? ""
                let displayName = data["displayName"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let referenceConnectyCubeID = data["referenceConnectyCubeID"] as? UInt ?? 0
                let story = data["story"] as? String ?? ""
                let createdAt = data["createdAt"] as? String ?? ""
                let updatedAt = data["updatedAt"] as? String ?? ""
                let displayPhoto = data["displayPhoto"] as? String ?? ""
                let score = data["score"] as? Double ?? 0
                return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, score: score,documentReference: queryDocumentSnapshot.reference)
                
            }
            self.tableView.reloadData()
        }
    }
    
    func getReviewsData(){
        
        db.collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
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
            self.tableView.reloadData()
        }
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let doctor = self.doctorList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorCell
        cell.doctor = doctor
        cell.doctorNickNameLabel.text = doctor.displayName
        cell.doctorNameLabel.text = (doctor.firstName ?? "") + "  " + (doctor.lastName ?? "")
        
        
        let imageRef = storage.reference(withPath: doctor.displayPhoto ?? "")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        cell.doctorImageView.image = img
                    }
                }
            } else {
                cell.doctorImageView.image = UIImage(named: "placeholder")
                
            }
        }
        
        cell.doctorStarLabel.text = String(format: "%.2f",doctor.score!)
        cell.doctorReviewLabel.text = ""
        cell.calculateReview(reviews: reviewList)
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let doctor = self.doctorList[indexPath.row]
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DoctorDetailViewController") as! DoctorDetailViewController
        viewController.doctor = doctor
        viewController.hidesBottomBarWhenPushed = true
        viewController.reviewList = reviewList
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
