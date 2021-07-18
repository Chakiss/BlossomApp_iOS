//
//  DoctorDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import UIKit

class DoctorDetailViewController: UIViewController {

    var doctor: Doctor?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = doctor?.displayName
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
