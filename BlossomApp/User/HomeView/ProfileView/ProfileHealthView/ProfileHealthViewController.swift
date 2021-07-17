//
//  ProfileHealthViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/7/2564 BE.
//

import UIKit
import DLRadioButton

class ProfileHealthViewController: UIViewController {

    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var acneTypeView: UIView!
    @IBOutlet weak var acneType: DLRadioButton!
    
    @IBOutlet weak var skinTypeView: UIView!
    @IBOutlet weak var skinType: DLRadioButton!
    
    @IBOutlet weak var allergicDrugView: UIView!
    @IBOutlet weak var allergicDrugType: DLRadioButton!
    @IBOutlet weak var allergicDrugTextField: UITextField!
    
    @IBOutlet weak var acneCaredDescriptionView: UIView!
    @IBOutlet weak var acneCaredType: DLRadioButton!
    @IBOutlet weak var acneCaredTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        informationView.addConerRadiusAndShadow()
    
        
        
        
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
