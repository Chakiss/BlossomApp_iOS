//
//  PreFormViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 22/7/2564 BE.
//

import UIKit
import DLRadioButton
import Firebase

class PreFormViewController: UIViewController {

    
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var topicButton: DLRadioButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    var selectedImage1: Bool = false
    var selectedImage2: Bool = false
    var selectedImage3: Bool = false
    
    var appointmentID: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topicButton.isMultipleSelectionEnabled = true
        self.submitButton.layer.cornerRadius = 22
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView1.isUserInteractionEnabled = true
        imageView1.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView2.isUserInteractionEnabled = true
        imageView2.addGestureRecognizer(tapGestureRecognizer2)
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView3.isUserInteractionEnabled = true
        imageView3.addGestureRecognizer(tapGestureRecognizer3)
    
    }
    
    
    
    @IBAction func submit() {
        var image1String = ""
        if selectedImage1 == true {
            if let imageData = imageView1.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image1String = encodeString
                
            }
        }
        
        var image2String = ""
        if selectedImage2 == true {
            if let imageData = imageView2.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image2String = encodeString
            }
        }
        
        var image3String = ""
        if selectedImage3 == true {
            if let imageData = imageView3.image!.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                image3String = encodeString
            }
        }
        
        var selectedButton:String = ""
        for button in topicButton.selectedButtons() {
            let title = (button.titleLabel?.text)! as String
            if selectedButton.isEmpty {
                selectedButton = title
               } else {
                selectedButton += ",\(title)"
               }
        }
        let formData = ["เรื่องที่ปรึกษา":selectedButton]
        
        var attachImage: [String] = []
        
        if !image1String.isEmpty {
            attachImage.append(image1String)
        }
        
        if !image2String.isEmpty {
            attachImage.append(image2String)
        }
        
        if !image3String.isEmpty {
            attachImage.append(image3String)
        }
        
        
        ProgressHUD.show()
        let payload = ["appointmentID": self.appointmentID,
                       "type": "pre",
                       "images": attachImage,
                       "form": formData ] as [String : Any] 
        
        functions.httpsCallable("app-appointments-updateForm").call(payload) { result, error in
            ProgressHUD.dismiss()
            
        }
        self.navigationController?.popToRootViewController(animated: false)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .appointment
            appDelegate.handleDeeplinking()
            
            self.dismiss(animated: false, completion: {
            
            })

        }
         
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        ImagePickerManager().pickImage(self){ image in
            let tappedImage = tapGestureRecognizer.view as! UIImageView
            if tappedImage.tag == 1 {
                self.imageView1.image = image
                self.selectedImage1 = true
            } else if tappedImage.tag == 2 {
                self.imageView2.image = image
                self.selectedImage2 = true
            } else {
                self.imageView3.image = image
                self.selectedImage3 = true
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
