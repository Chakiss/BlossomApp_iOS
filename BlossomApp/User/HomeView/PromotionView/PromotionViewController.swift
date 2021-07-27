//
//  PromotionViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Kingfisher
import Alamofire

class PromotionViewController: UIViewController {

    var promotion: Promotion!
    
    @IBOutlet var promotionImageView: UIImageView!
    
    @IBOutlet var descriptionView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var termconView: UIView!
    @IBOutlet var termconLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "โปรโมชั่น"
        
        
        descriptionView.addConerRadiusAndShadow()
        termconView.addConerRadiusAndShadow()
        
        
        
        
         
         
        let url = URL(string: self.promotion.image)
        promotionImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderHero"))
        
        self.descriptionLabel.text = promotion.description
        self.termconLabel.text = promotion.termcon
        // Do any additional setup after loading the view.
    }
    
   
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionImageCell", for: indexPath) as! PromotionImageCell
//            let url = URL(string: self.promotion.image)
//            cell.promotionImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderHero"))
//
//            return cell
//
//        } else if indexPath.row == 1 {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTextCell", for: indexPath) as! PromotionTextCell
//            cell.titleLabel.text = "รายละเอียดโปรโมชั่น"
//            cell.descriptionLabel.text = promotion.description
//            return cell
//
//        } else if indexPath.row == 2 {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTextCell", for: indexPath) as! PromotionTextCell
//            cell.titleLabel.text = "ข้อกำหนดและเงื่อนไขการใช้งาน"
//            cell.descriptionLabel.text = promotion.termcon
//            return cell
//        }
//        return UITableViewCell()
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
