//
//  BlossomReviewViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 27/7/2564 BE.
//

import UIKit
import Firebase
import GSImageViewerController

class BlossomReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

    @IBOutlet weak var tableView: UITableView!
    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var reviews:[BlossomReview] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReview()
        // Do any additional setup after loading the view.
    }
    
    func getReview() {
        db.collection("review")
            .getDocuments { snapshot, error in
                self.reviews =  snapshot?.documents.map { document -> BlossomReview in

                    let data = document.data()
                    let review = BlossomReview()
                
                    review.image = data["image"] as! String
                    review.title = data["title"] as! String
                
                    return review

                } ?? []
                
                self.tableView.reloadData()
            }
        
        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
     }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = self.reviews[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlossomReviewCell", for: indexPath) as! BlossomReviewCell
        
        let imageRef = self.storage.reference().child(review.image)
        let placeholderImage = UIImage(named: "placeholder")
        cell.reviewImageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        
       
        
        return cell
     }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! BlossomReviewCell
        
        let imageInfo   = GSImageInfo(image: cell.reviewImageView.image!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: cell.reviewImageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
        
    }
   

}
