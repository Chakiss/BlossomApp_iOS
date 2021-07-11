//
//  PromotionViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Kingfisher
import Alamofire

class PromotionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var promotion: Promotion!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "โปรโมชั่น"
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else if indexPath.row == 1 {
            return UITableView.automaticDimension
        } else if indexPath.row == 2 {
            return UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionImageCell", for: indexPath) as! PromotionImageCell
            let url = URL(string: self.promotion.image)
            cell.promotionImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderHero"))

            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTextCell", for: indexPath) as! PromotionTextCell
            cell.titleLabel.text = "รายละเอียดโปรโมชั่น"
            cell.descriptionLabel.text = promotion.description
            return cell
            
        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTextCell", for: indexPath) as! PromotionTextCell
            cell.titleLabel.text = "ข้อกำหนดและเงื่อนไขการใช้งาน"
            cell.descriptionLabel.text = promotion.termcon
            return cell
        }
        return UITableViewCell()
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
