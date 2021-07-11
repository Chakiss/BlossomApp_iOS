//
//  ProductListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Alamofire


class ProductListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var products: [Products] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ยา"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchProduct()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = products[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.productNameLabel.text = product.name
        cell.productPriceLabel.text = product.price ?? "" + " บาท"
        
        let url = URL(string: product.image ?? "")
        cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        cell.productImageView.addConerRadiusAndShadow()
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        viewController.product = product
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    

}


// MARK: - Alamofire
extension ProductListViewController {
    func fetchProduct(){
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=Aq1p3BC8ZSyBb-IW2QEOxT_JppMvbjSB3DKWRC2E6ziaxgDeJRK00dSzkgcbCSS_AIpESUe-Rz47suWiX2MjqA, email=oaf@blossomclinic.com"
        ]
        
        AF.request("https://www.shipnity.pro/api/v2/products?per_page=50",method: .get ,headers: headers)
            .validate()
            .responseDecodable(of: ProductsResponse.self) { (response) in
                guard let productsResponse = response.value else { return }
                self.products = productsResponse.products ?? []
                self.tableView.reloadData()
            }
        
    }
}
