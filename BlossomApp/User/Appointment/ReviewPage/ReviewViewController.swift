//
//  ReviewViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 28/7/2564 BE.
//

import UIKit
import STRatingControl
import Firebase

class ReviewViewController: UIViewController {

    @IBOutlet weak var ratingControl: STRatingControl!
    
    @IBOutlet weak var reviewTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    var appointmentID: String = ""
    var doctorID: String = ""
    var customerID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingControl.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func doneButtonTapped() {
        
        ProgressHUD.show()
        let formData = ["วินิจฉัย":ratingControl.rating,
                        "แผนการรักษา":reviewTextField.text] as [String : Any]
        
        let payload = ["appointmentID": self.appointmentID,
                       "type": "post",
                       "images": [],
                       "form": formData ] as [String : Any]
        
        functions.httpsCallable("app-appointments-updateForm").call(payload) { result, error in
            ProgressHUD.dismiss()
            
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .appointment
            appDelegate.handleDeeplinking()
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })

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

extension ReviewViewController: STRatingControlDelegate {
  
  func didSelectRating(_ control: STRatingControl, rating: Int) {
    print("Did select rating: \(rating)")
  }
  
}
