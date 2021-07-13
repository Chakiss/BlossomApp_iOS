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
    
    
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ยา"
        // Do any additional setup after loading the view.
        let button = UIBarButtonItem(title: "Cart", style: .plain, target: self, action: #selector(ProductListViewController.showCartDetail))
        self.navigationItem.rightBarButtonItem = button
        
       
        
    }
    
    @objc
    private func showCartDetail() {
        
        if CartManager.shared.currentCart == nil {
            CartManager.shared.newCart()
        }
        
        let viewController = CartViewController.initializeInstance(cart: CartManager.shared.currentCart!)
        self.navigationController?.pushViewController(viewController, animated: true)
        
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
        
        cell.delegate = self
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

extension ProductListViewController: ProductCellDelegate {
    
    func productCellDidAddToCart(cell: ProductCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let product = products[indexPath.row]
        CartManager.shared.addItem(product)
        
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
