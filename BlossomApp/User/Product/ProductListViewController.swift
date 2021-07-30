//
//  ProductListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Alamofire
import SwiftyUserDefaults

protocol ProductListViewControllerDelegate: AnyObject {
    func productListDidSelect(product: Product)
}

class ProductListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    private var products: [Product] = []
    
    var customer: Customer?
    weak var delegate: ProductListViewControllerDelegate?
    
    static func initializeInstance(customer: Customer?) -> ProductListViewController? {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let productList = storyBoard.instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController
        productList?.hidesBottomBarWhenPushed = true
        productList?.customer = customer
        return productList
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ยา"
        // Do any additional setup after loading the view.
        if customer == nil {
            customer = CustomerManager.sharedInstance.customer
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchProduct()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCartButton()
    }
    
    private func updateCartButton() {
        guard self.navigationController?.viewControllers.firstIndex(of: self) == 0 || Defaults[\.role] == "doctor" else {
            return
        }
        let count = CartManager.shared.currentCart?.items.count ?? 0
        let icon = count > 0 ? "cart.fill" : "cart"
        let cartButton = UIBarButtonItem(image: UIImage(systemName: icon), style: .plain, target: self, action: #selector(showCartDetail))
        self.navigationItem.rightBarButtonItem = cartButton
    }
    
    @objc
    private func showCartDetail() {
        
        guard CartManager.shared.currentCart != nil else {
            showError(message: "ยังไม่มีสินค้าในตะกร้า")
            return
        }
        
        let viewController = CartViewController.initializeInstance(cart: CartManager.shared.currentCart!, customer: customer)
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = products[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.selectionStyle = .none
        cell.delegate = self
        cell.productNameLabel.text = product.name
        cell.productPriceLabel.text = product.priceInSatang().satangToBaht().toAmountText() + " บาท"
        
        let url = URL(string: product.image ?? "")
        cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        cell.productImageView.addConerRadiusAndShadow()
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        
        guard delegate == nil else {
            return
        }
        
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

        guard let delegate = delegate else {
            buttonHandlerAddToCart(cell.addToCartButton)
            CartManager.shared.addItem(product)
            updateCartButton()
            return
        }
        
        delegate.productListDidSelect(product: product)
    }
    
}

// MARK: - Alamofire
extension ProductListViewController {
    func fetchProduct(){
        ProgressHUD.show()
        let headers: HTTPHeaders = [
            "Authorization": "Token token=Aq1p3BC8ZSyBb-IW2QEOxT_JppMvbjSB3DKWRC2E6ziaxgDeJRK00dSzkgcbCSS_AIpESUe-Rz47suWiX2MjqA, email=oaf@blossomclinic.com"
        ]
        
        AF.request("https://www.shipnity.pro/api/v2/products?per_page=50",method: .get ,headers: headers)
            .validate()
            .responseDecodable(of: ProductsResponse.self) { (response) in
                ProgressHUD.dismiss()
                guard let productsResponse = response.value else { return }
                self.products = productsResponse.products ?? []
                self.tableView.reloadData()
            }
        
    }
}

extension ProductListViewController {
    
    func buttonHandlerAddToCart(_ sender: UIButton) {
            
        let buttonPosition : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)!
        let cell = tableView.cellForRow(at: indexPath) as! ProductCell
        let imageViewPosition : CGPoint = cell.productImageView.convert(cell.productImageView.bounds.origin, to: self.view)
        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.productImageView.frame.size.width, height: cell.productImageView.frame.size.height))
        imgViewTemp.backgroundColor = .white
        imgViewTemp.image = cell.productImageView.image
        animation(tempView: imgViewTemp)
        
    }
    
    func animation(tempView : UIView)  {
        self.navigationController?.view.addSubview(tempView)
        UIView.animate(withDuration: 0.1,
                       animations: {
                        tempView.animationZoom(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.3, animations: {
                
                tempView.animationZoom(scaleX: 0.2, y: 0.2)
                tempView.animationRotated(by: CGFloat(Double.pi))
                
                tempView.frame.origin.x = self.view.frame.width - 40
                tempView.frame.origin.y = self.navigationController?.navigationBar.frame.height ?? 0 - 10
                
            }, completion: { _ in
                tempView.removeFromSuperview()
            })
            
        })
    }
}
