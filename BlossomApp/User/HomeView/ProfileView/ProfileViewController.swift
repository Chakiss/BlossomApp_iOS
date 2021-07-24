//
//  ProfileViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    var barButton:UIBarButtonItem = UIBarButtonItem()
    
    lazy var functions = Functions.functions()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    var customer:Customer?

    private lazy var profileInformationViewController: ProfileInformationViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ProfileInformationViewController") as! ProfileInformationViewController
        return viewController
    }()

    private lazy var profileHealthViewController: ProfileHealthViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "ProfileHealthViewController") as! ProfileHealthViewController
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"

        setupView()
        getCustomer()
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        NotificationCenter.default.addObserver(self, selector: #selector(self.profileChanged), name:Notification.Name("BlossomProfileChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.profileChanged), name:Notification.Name("BlossomHealthChanged"), object: nil)
    }
    
    
    @objc func back(sender: UIBarButtonItem) {

        if self.barButton.isEnabled == true {
            
            let alert = UIAlertController(title: "โปรไฟล์มีการแก้ไข", message: "คุณค้องการแก้ไขโปรไฟล์หรือไม่​ ?",         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: { _ in
            }))
            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(_: UIAlertAction!) in
                self.saveUserData()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
        
        
        self.profileImageView.circleView()
        self.profileImageView.addShadow()
        
        barButton = UIBarButtonItem(title: "บันทึก", style: .plain, target: self, action: #selector(self.saveUserData))

        barButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "SukhumvitSet-Bold", size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
        ], for: .normal)
        barButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "SukhumvitSet-Bold", size: 14)!,
            NSAttributedString.Key.foregroundColor : UIColor(white: 1.0, alpha: 0.3),
        ], for: .disabled)
        
        barButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButton

        
    }
    
    func getCustomer(){
        
        db.collection("customers").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            self.customer = snapshot?.data().map({ documentData -> Customer in
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
            })
            self.profileInformationViewController.customer = self.customer
            self.profileInformationViewController.displayInformation()
            self.profileHealthViewController.customer = self.customer
            self.displayInformation()
        }
    }
    
    
    func displayInformation() {
        
        let imageRef = storage.reference(withPath: customer?.displayPhoto ?? "")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error == nil {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profileImageView.image = img
                    }
                }
            } else {
                self.profileImageView.image = UIImage(named: "placeholder")
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BlossomProfileChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BlossomHealthChanged"), object: nil)
        
    }
    
    
    @objc func saveUserData(){
        
        ProgressHUD.show()
        let payload = ["birthDate": customer?.birthDayString,
                       "firstName": profileInformationViewController.nameTextField.text!,
                       "lastName": profileInformationViewController.surNameTextField.text!,
                       "gender": customer?.genderString,
                       "address": profileInformationViewController.addressTextField.text!,
                       "provinceID": "0",
                       "districtID": "0",
                       "subDistrictID": "0",
                       "zipcodeID": "0"]
        
        functions.httpsCallable("app-users-updateProfile").call(payload) { result, error in
            Auth.auth().currentUser?.reload()
            self.saveHealtData()
            
        }
        
    }
    
    func saveHealtData(){
        var acneCaredString = customer?.acneCaredDescription
        if (profileHealthViewController.acneCaredTextField != nil) {
            acneCaredString = profileHealthViewController.acneCaredTextField.text
        }
        
        var allergicDrugString = customer?.allergicDrug
        if (profileHealthViewController.allergicDrugTextField != nil) {
            allergicDrugString = profileHealthViewController.allergicDrugTextField.text
        }
        
        var skinTypeString = customer?.skinType
        if !profileHealthViewController.skinTypeString.isEmpty {
            skinTypeString = profileHealthViewController.skinTypeString
        }
        
        var acneTypeString = customer?.acneType
        if !profileHealthViewController.acneTypeString.isEmpty {
            acneTypeString = profileHealthViewController.acneTypeString
        }
        
        let payloadHealth = ["skinType": skinTypeString,
                             "acneType": acneTypeString,
                             "acneCaredDescription": acneCaredString,
                             "allergicDrug": allergicDrugString]
        
        functions.httpsCallable("app-users-updateMedicalProfile").call(payloadHealth) { result, error in
            Auth.auth().currentUser?.reload()
            ProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc private func profileChanged(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        barButton.isEnabled = true
    }
    
    // MARK:- Update Profile Picture
    // app-users-uploadAvatar
    @IBAction func selectImagePicker(){

        ImagePickerManager().pickImage(self){ image in
            //here is the image
            self.uploadAvatar(image: image)
            
        }
        
        
    }
    
    
    @objc func uploadAvatar(image: UIImage){
        
        if let imageData = image.jpeg(.low) {
            print(imageData.count)
            let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
            
            ProgressHUD.show()
            let payload = ["type": "customer",
                           "dataURI": "data:image/jpeg;base64, \(strBase64)"
            ]
            
            functions.httpsCallable("app-users-uploadAvatar").call(payload) { result, error in
                let data = result?.data as! [String : String]
                let imageURL = data["imageUrl"] ?? ""
                let imageRef = self.storage.reference(withPath:imageURL)
                imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                    if error == nil {
                        if let imgData = data {
                            self.profileImageView.image = UIImage(data: imgData)
                            
                        }
                    } else {
                        self.profileImageView.image = UIImage(named: "placeholder")
                        
                    }
                }
                ProgressHUD.dismiss()
                
            }
        }
        
        
    }
    
    
    private func setupView() {
        
        add(asChildViewController: profileInformationViewController)
        setupSegmentedControl()
        
        let user = Auth.auth().currentUser
        self.nameLabel.text = user?.displayName
        
        
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "ข้อมูลส่วนตัว", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "ข้อมูลสุขภาพ", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)

        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: profileHealthViewController)
            add(asChildViewController: profileInformationViewController)
        } else {
            remove(asChildViewController: profileInformationViewController)
            add(asChildViewController: profileHealthViewController)
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        containerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    
    
    

}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
