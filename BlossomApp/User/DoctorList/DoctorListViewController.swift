//
//  DoctorListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Firebase
import FirebaseStorage
import GSImageViewerController
import SwiftDate

class DoctorListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var consultImage: UIImageView!
    
    var doctorList: [Doctor] = []
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "แพทย์"
        // Do any additional setup after loading the view.
        
        getDoctorData()
        getConsultOnlineImage()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.consultImage.addGestureRecognizer(tap)
        self.consultImage.isUserInteractionEnabled = true
        
        
    }
    
    func getConsultOnlineImage() {
        let imageRef = storage.reference(withPath: "onlineconsult/currentmonth/image.png")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.consultImage.image = img
                    }
                }
            }
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
        let imageInfo   = GSImageInfo(image: self.consultImage.image!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: self.consultImage)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }
    
    
    
    func getDoctorData() {
        
        db.collection("doctors")
            .getDocuments { doctorDocuments, error in
                
                guard error == nil else {
                    return
                }
                
                guard let doctorDocument = doctorDocuments?.documents else {
                    return
                }
                
                self.doctorList = doctorDocument.map { queryDocumentSnapshot -> Doctor in
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
                    let appointment = data["appointment"] as? Int ?? 0
                    let review = data["review"] as? Int ?? 0
                    
                    
                    let doctor = Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, score: score,documentReference: queryDocumentSnapshot.reference)
                    doctor.appointment = appointment
                    doctor.review = review
                    
                    return doctor
                    
                }
                self.checkSlotDoctor()
                self.tableView.reloadData()
                
                
            }
    }
    
    func checkSlotDoctor() {
        for (index, doctor) in self.doctorList.enumerated() {
            db.collection("doctors")
                .document(doctor.id ?? "")
                .collection("slots")
                .whereField("platform", isEqualTo: "app")
                .getDocuments { daySlot, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let slotDocuments = daySlot?.documents else {
                        return
                    }
                    
                    for queryDocumentSnapshot in slotDocuments {
                        let id = queryDocumentSnapshot.documentID
                        let data = queryDocumentSnapshot.data()
                        let date = data["date"] as! Timestamp
                        
                        let today = Date().startOfDay
                        let region = Region(calendar: Calendar(identifier: .gregorian), zone: Zones.gmt, locale: Locales.englishUnitedStates)
                        let d = date.dateValue().startOfDay
                        
                        if d.date.startOfDay == today {
                            self.doctorList[index].isHaveSlotToday = true
                            self.doctorList.sort { $0.isHaveSlotToday && !$1.isHaveSlotToday }
                            self.tableView.reloadData()
                        }
                    }
                }
            
        }
        //
    }
    
//    func getReviewsData(){
//
//        db.collection("reviews").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            self.reviewList = documents.map { queryDocumentSnapshot -> Reviews in
//                let data = queryDocumentSnapshot.data()
//
//                let id = queryDocumentSnapshot.documentID
//                let appointmentReference = data["appointmentReference"] as? DocumentReference
//                let message = data["message"] as? String ?? ""
//                let createdAt = data["createdAt"] as? String ?? ""
//                let doctorReference = data["doctorReference"] as! DocumentReference
//                let score = data["score"] as? Int ?? 0
//                let type = data["type"] as? String ?? ""
//                let updatedAt = data["updatedAt"] as? String ?? ""
//                let patientReference = data["patientReference"] as? DocumentReference
//
//                return Reviews(id: id, appointmentReference: appointmentReference, message: message, createdAt: createdAt, doctorReference: doctorReference, score: score, type: type, updatedAt: updatedAt, patientReference: patientReference)
//
//            }
//            self.tableView.reloadData()
//        }
//    }
    
//    func getAppointment() {
//        db.collection("appointments")
//            .addSnapshotListener { snapshot, error in
//                self.appointmentList = (snapshot?.documents.map { queryDocumentSnapshot -> Appointment  in
//                    let data = queryDocumentSnapshot.data()
//                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
//                    let timeRef = data["timeReference"]  as? DocumentReference ?? nil
//                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
//                    let sessionStart = data["sessionStart"] as! Timestamp
//                    let sessionEnd = data["sessionEnd"]  as! Timestamp
//                    let isComplete = data["isCompleted"]  as! Bool
//                    let preForm = data["preForm"] as? [String:Any] ?? ["":""]
//                    let postForm = data["postForm"] as? [String:Any] ?? ["":""]
//
//                    let attachedImages = data["attachedImages"] as? [String] ?? []
//
//                    var appointment = Appointment(id: queryDocumentSnapshot.documentID, customerReference: cusRef!, doctorReference: doctorRef!, timeReference: timeRef!,sessionStart: sessionStart, sessionEnd: sessionEnd,preForm: preForm, postForm: postForm)
//                    appointment.isComplete = isComplete
//                    appointment.attachedImages = attachedImages
//                    return appointment
//                }) ?? []
//                self.tableView.reloadData()
//
//
//            }
//    }
    
    
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
        
        cell.doctorStarLabel.text = "4.75"//String(format: "%.2f",doctor.score!)
        cell.doctorReviewLabel.text = ""
        //cell.calculateReview(reviews: reviewList)
        //cell.calculateAppointMent(appointment: appointmentList)
        let review = doctor.review!
        cell.doctorReviewLabel.text = "\(review) รีวิว"
        
        let appointment = doctor.appointment!
        cell.doctorAppointmentLabel.text = "รักษา \(appointment) ครั้ง"
        
        if doctor.isHaveSlotToday == true {
            cell.doctorHaveSlotLabel.text = "ลงตรวจวันนี้"
        } else {
            cell.doctorHaveSlotLabel.text = ""
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let doctor = self.doctorList[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DoctorDetailViewController") as! DoctorDetailViewController
        viewController.doctor = doctor
        viewController.hidesBottomBarWhenPushed = true
        //viewController.reviewList = reviewList
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
