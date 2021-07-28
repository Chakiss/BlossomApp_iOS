//
//  ReviewViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 28/7/2564 BE.
//

import UIKit
import STRatingControl

class ReviewViewController: UIViewController {

    @IBOutlet weak var ratingControl: STRatingControl!
    
    @IBOutlet weak var reviewTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingControl.delegate = self

        // Do any additional setup after loading the view.
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
