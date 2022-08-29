//
//  ProductDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 10/7/2564 BE.
//

import UIKit
import Firebase

class ProductDetailViewController: UIViewController {

    var product:Product? = nil
    var set:Sets? = nil
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    
    private var quantity: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // shadow
        self.footerView.layer.shadowColor = UIColor.black.cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.footerView.layer.shadowOpacity = 0.1
        self.footerView.layer.shadowRadius = 4.0
        
        if product != nil {
            self.title = product?.name
            
            productNameLabel.text = product?.name
            productPriceLabel.text = product?.priceInSatang().satangToBaht().toAmountText()
            productDescriptionLabel.text = product?.description_long?.htmlToString
            
            let url = URL(string: product?.image ?? "")
            productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            productImageView.addConerRadiusAndShadow()
            
            decreaseButton.addConerRadiusAndShadow()
            addButton.addConerRadiusAndShadow()
            calculatePrice()
        }
        
        if set != nil {
            productNameLabel.text = set?.name
            
            productPriceLabel.text = set?.price
            
            db.collection("set_product").document(set?.code ?? "").getDocument { documentSnapshot, error in
                let snapshotData = documentSnapshot?.data()
                let image = snapshotData?["image"] as? String ?? ""
                let description = snapshotData?["description"] as? String ?? ""
                
                self.productImageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"))
                self.productImageView.addConerRadiusAndShadow()
                self.productDescriptionLabel.text = description
            }
            
            productImageView.addConerRadiusAndShadow()
            
            decreaseButton.addConerRadiusAndShadow()
            addButton.addConerRadiusAndShadow()
            calculatePrice()
        }
    }
    
    @IBAction func addQuantity(_ sender: Any) {
        quantity += 1
        quantityLabel.text = "\(quantity)"
        calculatePrice()
    }
    
    @IBAction func decreaseQuantity(_ sender: Any) {
        quantity = max(1, quantity-1)
        quantityLabel.text = "\(quantity)"
        calculatePrice()
    }
    
    private func calculatePrice() {
        if product != nil {
            guard let itemPrice = product?.priceInSatang() else {
                return
            }
            let total = itemPrice*quantity
            priceLabel.text = "ราคา \(total.satangToBaht().toAmountText()) บาท"
        }
        
        if set != nil {
            guard let itemPrice = set?.priceInSatang() else {
                return
            }
            let total = itemPrice*quantity
            priceLabel.text = "ราคา \(total.satangToBaht().toAmountText()) บาท"
        }
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if product != nil {
            guard let product = product, let button = sender as? UIButton else {
                return
            }
            buttonHandlerAddToCart(button)
            CartManager.shared.addItem(product, quantity: quantity)
        }
        
        if set != nil {
            guard let product = set, let button = sender as? UIButton else {
                return
            }
            buttonHandlerAddToCart(button)
            CartManager.shared.addSet(product, quantity: quantity)
        }
    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension ProductDetailViewController {
    
    func buttonHandlerAddToCart(_ sender: UIButton) {
        let imageViewPosition: CGPoint = productImageView.convert(productImageView.bounds.origin, to: self.view)
        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: productImageView.frame.size.width, height: productImageView.frame.size.height))
        imgViewTemp.backgroundColor = .white
        imgViewTemp.image = productImageView.image
        animation(tempView: imgViewTemp, button: sender)
    }
    
    func animation(tempView : UIView, button: UIButton)  {
        self.view.addSubview(tempView)
        UIView.animate(withDuration: 0.1,
                       animations: {
                        tempView.animationZoom(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.3, animations: {
                
                tempView.animationZoom(scaleX: 0.2, y: 0.2)
                tempView.animationRotated(by: CGFloat(Double.pi))
                
                let targetPosition: CGPoint = button.convert(button.bounds.origin, to: self.view)
                tempView.frame.origin.x = self.view.frame.midX
                tempView.frame.origin.y = targetPosition.y
                
            }, completion: { _ in
                tempView.removeFromSuperview()
            })
            
        })
    }
}
