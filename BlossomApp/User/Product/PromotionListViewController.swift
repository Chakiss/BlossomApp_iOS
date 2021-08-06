//
//  PromotionListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/8/2564 BE.
//

import UIKit
import Firebase
import Kingfisher
import Alamofire

class PromotionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var customer:Customer?
    
    var promotions: [Promotion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPromotion()
        // Do any additional setup after loading the view.
    }
    
    func getPromotion() {
        db.collection("promotion")
            .getDocuments { snapshot, error in
                self.promotions =  snapshot?.documents.map { document -> Promotion in
    
                    let data = document.data()
                    let promotion = Promotion()
                    promotion.description = data["description"] as! String
                    promotion.image = data["image"] as! String
                    promotion.termcon = data["termcon"] as! String
                    promotion.link = data["deeplink"] as! String
                   
                    return promotion
                    
                } ?? []
                self.promotions.sort { $0.image < $1.image }
                
                self.tableView.reloadData()
            }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionListCell", for: indexPath) as! PromotionListCell
    
        let promotion = self.promotions[indexPath.row]
        let url = URL(string: promotion.image)
        DispatchQueue.main.async {
            cell.promotionImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderHero"))
        }
        cell.promotionLabel.text = promotion.description
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let promotion = self.promotions[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PromotionViewController") as! PromotionViewController
        viewController.promotion = promotion
        viewController.modalPresentationStyle = .fullScreen
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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
