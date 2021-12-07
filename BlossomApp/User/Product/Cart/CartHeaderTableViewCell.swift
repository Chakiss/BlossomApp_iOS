//
//  CartHeaderTableViewCell.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit
import SwiftyUserDefaults

protocol CartHeaderTableViewCellDelegate: AnyObject {
    func cartHeaderDidTapEditAddress()
    func cartHeaderApplyPromoCode(codeID: String)
}

class CartHeaderTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    struct Model {
        var dateString: String = ""
        var priceText: String = ""
        var addressText: String = ""
        var shippingText: String = ""
        var phoneNumberText: String = ""
        var orderDiscountText: String = ""
    }

    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shipingPriceLabel: UILabel!
    @IBOutlet weak var addressTitieLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editAddressButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var promoCodeTextfield: UITextField!
    @IBOutlet weak var promoCodeLabel: UILabel!
    
    @IBOutlet weak var orderDiscountLabel: UILabel!
    
    weak var delegate: CartHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.backgroundColor
        selectionStyle = .none
        stackViewContainer.addConerRadiusAndShadow()
        orderLabel.text = ""
        priceLabel.text = ""
        shipingPriceLabel.text = ""
        addressTitieLabel.text = ""
        addressLabel.text = ""
        phoneNumberLabel.text = ""
        editAddressButton.setTitle("แก้ไขที่อยู่", for: .normal)
        orderDiscountLabel.text = ""
        
        orderLabel.font = FontSize.body.bold()
        priceLabel.font = FontSize.body2.bold()
        shipingPriceLabel.font = FontSize.body2.regular()
        addressTitieLabel.font = FontSize.body2.regular()
        addressLabel.font = FontSize.body2.regular()
        phoneNumberLabel.font = FontSize.body2.regular()
        orderDiscountLabel.font = FontSize.body2.regular()
        
        editAddressButton.backgroundColor = UIColor.blossomPrimary3
        editAddressButton.roundCorner(radius: 17)
        
        promoCodeTextfield.delegate = self
        promoCodeLabel.font = FontSize.body2.bold()
        promoCodeLabel.isHidden = true
    }
    
    public func renderOrderHeader(_ model: Model) {
        orderLabel.text = "Order วันที่ \(model.dateString)"
        priceLabel.text = "ราคา \(model.priceText) บาท"
        shipingPriceLabel.text = "ค่าจัดส่ง \(model.shippingText) บาท"
        addressTitieLabel.text = "ที่อยู่จัดส่ง"
        addressLabel.text = model.addressText
        phoneNumberLabel.text = model.phoneNumberText
        editAddressButton.isHidden =  Defaults[\.role] == "doctor"
        
        orderDiscountLabel.text = "ส่วนลด \(model.orderDiscountText) บาท"
       
    }
    
    public func rendorPromoCode(isValid:Bool, discount:Double, promoCode:Promo_codes){
        promoCodeLabel.isHidden = false
        if isValid {
            self.promoCodeTextfield.text = promoCode.code
            self.promoCodeLabel.textColor = UIColor.blossomGreen
            if promoCode.discount_type == "percent" {
                self.promoCodeLabel.text = "รหัสส่วนลดพร้อมใช้งาน ลด \(promoCode.discount_value!)% \(discount) บาท"
            } else {
                self.promoCodeLabel.text = "รหัสส่วนลดพร้อมใช้งาน ลด \(discount) บาท"
            }
        } else {
            self.promoCodeLabel.textColor = UIColor.red
            self.promoCodeLabel.text = "ไม่พบรหัสส่วนลด"
        }
        self.setNeedsDisplay()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        delegate?.cartHeaderDidTapEditAddress()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        delegate?.cartHeaderApplyPromoCode(codeID: textField.text!)
        return true
    }
    /**
     
     */
    
}
