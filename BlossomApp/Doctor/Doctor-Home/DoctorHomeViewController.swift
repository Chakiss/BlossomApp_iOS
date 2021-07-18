//
//  DoctorHomeViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import UIKit
import Firebase

class DoctorHomeViewController: UIViewController {

    @IBOutlet weak var doctorImageView: UIImageView!
    
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    var doctor: Doctor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getDoctor()
    }
    
    func getDoctor(){
        db.collection("doctors").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            self.doctor = snapshot?.data().map({ documentData -> Doctor in
                print(documentData)
                let id = snapshot?.documentID ?? ""
                let createdAt = documentData["createdAt"] as? String ?? ""
                let story = documentData["story"] as? String ?? ""
                let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                let firstName = documentData["firstName"] as? String ?? ""
                let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                let updatedAt = documentData["updatedAt"] as? String ?? ""
                let displayName = documentData["displayName"] as? String ?? ""
                let email = documentData["email"] as? String ?? ""
                let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? String ?? ""
                let lastName = documentData["lastName"] as? String ?? ""
                let currentScore = documentData["currentScore"] as? String ?? ""
                
                return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto,currentScore: currentScore)
            })
            
            self.displayInformation()
        }
        
    }
    
    
    func displayInformation()  {
        self.doctorImageView.layer.cornerRadius = self.doctorImageView.bounds.height / 2
        let imageRef = storage.reference(withPath: self.doctor?.displayPhoto ?? "")
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
