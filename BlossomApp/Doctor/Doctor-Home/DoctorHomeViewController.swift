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

        self.title = "หน้าแรก"

        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "user"), for: .normal)
        button.addTarget(self, action: #selector(self.profileButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
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
                let currentScore = documentData["currentScore"] as? Double ?? 0.0
                let reference = snapshot?.reference
                
                return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto,currentScore: currentScore,documentReference: reference!)
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
            let storyboard = UIStoryboard(name: "Doctor", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DoctorProfileViewController") as! DoctorProfileViewController
            viewController.doctor = self.doctor
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
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
