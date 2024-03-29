//
//  ProductListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import Alamofire
import SwiftyUserDefaults
import Firebase
import FirebaseFirestore

protocol ProductListPrescriptionDelegate: AnyObject {
    func productListDidFinish()
}

protocol ProductListViewControllerDelegate: AnyObject {
    func productListDidSelect(product: Product)
    func productListDidSelect(set: Sets)
}

class ProductListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var headerImageView: UIImageView!
    
    private var products: [Product] = []
    
    private var setProducts: [Sets] = []
    
    let db = Firestore.firestore()
    
    var deeplinkID: String = ""
    var customer: Customer?
    weak var delegate: ProductListViewControllerDelegate?
    weak var prescriptDelegate: ProductListPrescriptionDelegate?
    
    static func initializeInstance(customer: Customer?, delegate: ProductListViewControllerDelegate? = nil, prescriptDelegate: ProductListPrescriptionDelegate? = nil) -> ProductListViewController? {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let productList = storyBoard.instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController
        productList?.hidesBottomBarWhenPushed = true
        productList?.customer = customer
        productList?.delegate = delegate
        productList?.prescriptDelegate = prescriptDelegate
        return productList
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ผลิตภัณฑ์"
        // Do any additional setup after loading the view.
        if customer == nil {
            customer = CustomerManager.sharedInstance.customer
        }
        
        if prescriptDelegate != nil {
            let newBackButton = UIBarButtonItem(title: "ปิด", style: .plain, target: self, action: #selector(closePrescript(sender:)))
            self.navigationItem.leftBarButtonItem = newBackButton
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.headerImageView.addGestureRecognizer(tap)
        self.headerImageView.isUserInteractionEnabled = true
    }
    
    @objc private func closePrescript(sender: UIBarButtonItem) {
        prescriptDelegate?.productListDidFinish()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        guard let customer = customer else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        let viewController = CartViewController.initializeInstance(cart: CartManager.shared.currentCart!, customer: customer, prescriptDelegate: prescriptDelegate)
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if section == 0 {
            return setProducts.count
        }
        else {
            return products.count
        }
        */
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        if indexPath.section == 0 {
            let setproduct = setProducts[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            
            cell.selectionStyle = .none
            cell.delegate = self
            cell.productNameLabel.text = setproduct.name
            cell.productPriceLabel.text = setproduct.price! + " บาท"
            
            
            db.collection("set_product").document(setproduct.code ?? "").getDocument { documentSnapshot, error in
                let snapshotData = documentSnapshot?.data()
                let image = snapshotData?["image"] as? String ?? ""
                let description = snapshotData?["description"] as? String ?? ""
                cell.productImageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"))
                cell.productImageView.addConerRadiusAndShadow()
                cell.inventoryLabel.text = description
            }
            
            return cell
        } else {
         */
            let product = products[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            
            cell.selectionStyle = .none
            cell.delegate = self
            cell.productNameLabel.text = product.name
            cell.productPriceLabel.text = product.priceInSatang().satangToBaht().toAmountText() + " บาท"
            
            let url = URL(string: product.image ?? "")
            cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            cell.productImageView.addConerRadiusAndShadow()
            
            
            cell.inventoryLabel.text = product.description_short?.count ?? 0 > 0 ? product.description_short : "Set ผลิตภัณฑ์"
            
            return cell
       // }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if indexPath.section == 0 {
            let setProduct = setProducts[indexPath.row]
            
            guard delegate == nil else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
            viewController.set = setProduct
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            
        } else {
         */
            let product = products[indexPath.row]
            
            guard delegate == nil else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
            viewController.product = product
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        //}
    }
    
    func checkDeepLink() {
        if !deeplinkID.isEmpty {
            let product = self.products.filter{ $0.code == deeplinkID }.first
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
            viewController.product = product
            viewController.hidesBottomBarWhenPushed = true
            
            deeplinkID = ""
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PromotionListViewController") as! PromotionListViewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ProductListViewController: ProductCellDelegate {
    
    func productCellDidAddToCart(cell: ProductCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        

//        if indexPath.section == 0 {
//            let setProduct = setProducts[indexPath.row]
//
//            guard let delegate = delegate else {
//                buttonHandlerAddToCart(cell.addToCartButton)
//                CartManager.shared.addSet(setProduct)
//                updateCartButton()
//                return
//            }
//
//            delegate.productListDidSelect(set: setProduct)
//        } else {
//
            let product = products[indexPath.row]
            
            guard let delegate = delegate else {
                buttonHandlerAddToCart(cell.addToCartButton)
                CartManager.shared.addItem(product)
                updateCartButton()
                return
            }
            
            delegate.productListDidSelect(product: product)
       // }
    }
    
}

// MARK: - Alamofire
extension ProductListViewController {
    func fetchProduct(){
        ProgressHUD.show()
        let headers: HTTPHeaders = [
            "Authorization": "Token token=Aq1p3BC8ZSyBb-IW2QEOxT_JppMvbjSB3DKWRC2E6ziaxgDeJRK00dSzkgcbCSS_AIpESUe-Rz47suWiX2MjqA, email=oaf@blossomclinic.com"
        ]
        
        AF.request("https://www.shipnity.pro/api/v2/products?per_page=50&category=32514",method: .get ,headers: headers)
            .validate()
            .responseDecodable(of: ProductsResponse.self) { (response) in
                ProgressHUD.dismiss()
                guard let productsResponse = response.value else { return }
                
                self.products = productsResponse.products ?? []
                self.products.reverse()
                
                self.setProducts = productsResponse.sets ?? []
                
                self.tableView.reloadData()
                self.checkDeepLink()
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
