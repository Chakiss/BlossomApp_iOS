//
//  CartViewController.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit
import SwiftyUserDefaults

protocol UpdateCartViewControllerDelegate: AnyObject {
    func cartDidUpdate(order: Order)
    func appointmentOrderSuccess(orderID: String)
}

extension UpdateCartViewControllerDelegate {
    func cartDidUpdate(order: Order) {}
    func appointmentOrderSuccess(orderID: String) {}
}

class CartViewController: UIViewController {
    
    enum Section: Int {
        case header = 0
        case item
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    
    private var cartHeaderModel: CartHeaderTableViewCell.Model?
    private var cart: Cart?
    private var customer: Customer?
    private var currentCart: Bool = true
    private var shippingFee: Double = 0.0
    private var shippingBy: String = ""
    
    weak var delegate: UpdateCartViewControllerDelegate?
    weak var prescriptDelegate: ProductListPrescriptionDelegate?
    
    private var promoCodeID: Int = 0
    private var selectedPromoCode: Promo_codes?
    
    static func initializeInstance(cart: Cart, currentCart: Bool = true, customer: Customer?, prescriptDelegate: ProductListPrescriptionDelegate?) -> CartViewController {
        let controller: CartViewController = CartViewController(nibName: "CartViewController", bundle: Bundle.main)
        controller.cart = cart
        controller.currentCart = currentCart
        controller.customer = customer ?? CustomerManager.sharedInstance.customer
        controller.prescriptDelegate = prescriptDelegate
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    private func setupView() {
        self.checkoutButton.superview?.backgroundColor = UIColor.backgroundColor
        self.checkoutButton.backgroundColor = UIColor.blossomPrimary3
        self.checkoutButton.roundCorner(radius: 22)
        
        if Defaults[\.role] == "doctor" {
            self.checkoutButton.setTitle("สั่งยา", for: .normal)
        } else {
            self.checkoutButton.setTitle("ชำระเงิน", for: .normal)
        }
    }
    
    private func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.backgroundColor
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "CartHeaderTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CartHeaderTableViewCell")
        self.tableView.register(UINib(nibName: "CartItemTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CartItemTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CustomerManager.sharedInstance.reloadCustomerData { customer in
            self.customer = customer
        }
        
        let model = CartHeaderTableViewCell.Model(
            dateString: String.today(),
            priceText: "",
            addressText: customer?.address?.formattedAddress ?? "-",
            shippingText: "",
            phoneNumberText: customer?.phoneNumber?.phonenumberformat() ?? "-",
            orderDiscountText: "0"
        )
        self.cartHeaderModel = model
        updateTotalPrice()
        tableView.reloadData()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ((self.cart?.purchaseOrder?.promoCode) != nil) {
            self.rendorPromoCode((self.cart?.purchaseOrder?.promoCode)!)
        }
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "ตะกร้าสินค้า"
                
        setupView()
        setupTableView()
        
    }

    private func updateTotalPrice() {
        
        // TODO shipnity
        ProgressHUD.show()
        APIProduct.calculateShipping(items: self.cart?.getPurcahseAttributes() ?? []) { response in
            ProgressHUD.dismiss()
            guard let response = response else {
                self.showAlertDialogue(title: "ขออภัย", message: "ไม่สามารถส่งคำสั่งซื้อได้ในขณะนี้", completion: {
                })
                return
            }
            
            let shippingFeeArray = response as [ShippingFee]
            if shippingFeeArray.count > 0 {
                self.shippingFee = shippingFeeArray.first?.cost ?? 0.0
                self.shippingBy = shippingFeeArray.first?.name ?? ""
            } else {
                self.shippingFee = 60
                self.shippingBy = "J&T Express"
            }
            
            self.updatePricewithShipping()
            //}
        }.request()
        
    }
    
    private func updatePricewithShipping() {
        self.cartHeaderModel?.shippingText = String(format: "%.2f", self.shippingFee)
        let total = self.cart?.calculateTotalPriceInSatang().satangToBaht() ?? 0
        
        let orderDiscount = self.cart?.purchaseOrder?.orderDiscount ?? "0"
        self.cartHeaderModel?.orderDiscountText = orderDiscount
        
        
        
        let promoCode = self.selectedPromoCode ?? self.cart?.purchaseOrder?.promoCode
        var promoDiscount = 0.0
        if promoCode?.discount_type == "percent" {
            let total = self.cart?.calculateTotalPriceInSatang().satangToBaht() ?? 0
            promoDiscount =  (total * Double(promoCode?.discount_value ?? "1")!) / 100
        } else {
            promoDiscount = Double(promoCode?.discount_value ?? "0")!
        }
        
        
        self.cart?.shippingFee = Int(self.shippingFee)
        let totalText = (total + self.shippingFee - (Double(orderDiscount) ?? 0) - promoDiscount).toAmountText()
        self.cartHeaderModel?.priceText = totalText
        self.checkoutButton.isEnabled = self.cart?.items.count ?? 0 > 0
        self.checkoutButton.alpha = (self.checkoutButton.isEnabled ) ? 1.0 : 0.5
        
        
        self.tableView.reloadData()
    }
    
    
    private func checkSetProduct() -> Bool {
        if let setProduct =  cart?.items.filter({ $0.product.code == "37" || $0.product.code == "38" || $0.product.code == "39" || $0.product.code == "40" || $0.product.code == "41" || $0.product.code == "42" || $0.product.code == "43" })  {
            if setProduct.count > 0 {
                return true
            }
        }
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc
    private func addMoreProduct() {
        guard let productList = ProductListViewController.initializeInstance(customer: customer, delegate: self) else {
            return
        }
        self.navigationController?.pushViewController(productList, animated: true)
    }
    
    private func createOrder() {
        
        guard let customer = customer else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        guard let address = customer.address?.formattedAddress, !address.isEmpty else {
            if Defaults[\.role] == "doctor" {
                showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาแจ้งให้ผู้รับคำปรึกษาระบุที่อยู่จัดส่ง") { }
            } else {
                showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาระบุที่อยู่จัดส่ง") { [weak self] in
                    self?.showProfile()
                }
            }
            return
        }
        
        let name = (customer.firstName ?? "") + " " + (customer.lastName ?? "")
        let order = PurchaseOrder(customer: Int(customer.referenceShipnityID ?? "") ?? 0,
                                  name: name,
                                  address: address,
                                  tel: customer.phoneNumber ?? "",
                                  contactMethod: "phone",
                                  email: customer.email ?? "",
                                  annotation: "",
                                  tag: "app",
                                  shippingType: shippingBy,
                                  shippingFee: Int(shippingFee),
                                  orderDiscount: 0,
                                  purchasesAttributes: cart?.getPurcahseAttributes() ?? [],
                                  promo_code_id: self.promoCodeID)
        ProgressHUD.show()
        APIProduct.createOrder(po: CreateOrderRequest(order: order)) { [weak self] response in
            ProgressHUD.dismiss()
            guard let response = response,
                  let order = response.order else {
                self?.showAlertDialogue(title: "ขออภัย", message: "ไม่สามารถส่งคำสั่งซื้อได้ในขณะนี้", completion: {
                })
                return
            }
            self?.cart?.updatePO(order)
            self?.delegate?.cartDidUpdate(order: order)
            self?.gotoPaymentMethod()
        }.request()
    }
    
    private func updateOrder() {
        
        guard let customer = customer else {
            return
        }
        
        guard let address = customer.address?.formattedAddress, !address.isEmpty else {
            if Defaults[\.role] == "doctor" {
                showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาแจ้งให้ผู้รับคำปรึกษาระบุที่อยู่จัดส่ง") { }
            } else {
                showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาระบุที่อยู่จัดส่ง") { [weak self] in
                    self?.showProfile()
                }
            }
            return
        }
        
        let name = (customer.firstName ?? "") + " " + (customer.lastName ?? "")
        
        let order = PurchaseOrder(customer: Int(customer.referenceShipnityID ?? "") ?? 0,
                                  name: name,
                                  address: address,
                                  tel: customer.phoneNumber ?? "",
                                  contactMethod: "phone",
                                  email: customer.email ?? "",
                                  annotation: "",
                                  tag: "app",
                                  shippingType: shippingBy,
                                  shippingFee: Int(shippingFee),
                                  orderDiscount: 0,
                                  purchasesAttributes: cart?.getPurcahseAttributes() ?? [],
                                  promo_code_id: self.promoCodeID)
        ProgressHUD.show()
        APIProduct.updateOrder(orderID: cart?.purchaseOrder?.id ?? 0, po: UpdateOrderRequest(order: order)) { [weak self] response in
            ProgressHUD.dismiss()
            guard let response = response,
                  let order = response.order else {
                self?.showAlertDialogue(title: "ขออภัย", message: "ไม่สามารถส่งคำสั่งซื้อได้ในขณะนี้", completion: {
                })
                return
            }
            self?.cart?.updatePO(order)
            self?.delegate?.cartDidUpdate(order: order)
            self?.gotoPaymentMethod()
        }.request()
    }
    
    private func gotoPaymentMethod() {
        
        guard Defaults[\.role] != "doctor" else {
            self.navigationController?.popToRootViewController(animated: true)
            self.prescriptDelegate?.productListDidFinish()
            return
        }
        
        guard let cart = cart else {
            return
        }
        
        let paymentMethodViewController = PaymentMethodViewController.initializeInstance(cart: cart)
        paymentMethodViewController.delegate = delegate
        paymentMethodViewController.isBankTransfer = true
        self.navigationController?.pushViewController(paymentMethodViewController, animated: true)
        
    }
    
    @IBAction func checkoutCart(_ sender: Any) {
       
        /*
        guard customer?.isPhoneVerified == true else {
            if Defaults[\.role] == "doctor" {
                showAlertDialogue(title: "แจ้งเตือน", message: "ผู้รับคำปรึกษาต้องยืนยันเบอร์โทรศัพท์ก่อนทำการสั่งสินค้า") { }
            } else {
                showAlertDialogue(title: "แจ้งเตือน", message: "กรุณายืนยันเบอร์โทรศัพท์ก่อนทำการสั่งสินค้า") { [weak self] in
                    self?.showProfile()
                }
            }
            return
        }
        */
        
        guard let error = cart?.checkInventory() else {
            if currentCart {
                createOrder()
            } else {
                updateOrder()
            }
            return
        }
        
        showAlertDialogue(title: "แจ้งเตือน", message: error.localizedDescription) { }
    }
    
}

extension CartViewController: ProductListViewControllerDelegate {
    
    func productListDidSelect(product: Product) {
        cart?.addItem(product, quantity: 1)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CartViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard case .header = Section(rawValue: section) else {
            return cart?.items.count ?? 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartHeaderTableViewCell")
            
            if let cell = cell as? CartHeaderTableViewCell,
               let model = cartHeaderModel {
                cell.delegate = self
                cell.renderOrderHeader(model)
              
                
                return cell
            }
            
        case .item:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemTableViewCell")

            if let cell = cell as? CartItemTableViewCell,
               let items = cart?.items, indexPath.row < items.count {
                let item = items[indexPath.row]
                cell.render(item)
                cell.delegate = self
                return cell
            }

        }
        
        return UITableViewCell()

    }
    
}

extension CartViewController: CartItemTableViewCellDelegate {
    
    private func removeWarning(for item: Product) {
        showConfirmDialogue(title: "ลบสินค้า", message: "คุณต้องการลบสินค้า \(item.name ?? "") ออกจากตะกร้าใช่ไหม ?", completion: { [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.cart?.removeItem(item)
            self.updateTotalPrice()
            self.tableView.reloadData()
            
        })
    }
    
    func cellDidDecreaseItem(cell: CartItemTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell),
           let items = cart?.items, indexPath.row < items.count {
            let item = items[indexPath.row]
            
            guard item.quantity > 1 else {
                removeWarning(for: item.product)
                return
            }
            
            cart?.removeItem(item.product)
            updateTotalPrice()
            tableView.reloadData()
        }
    }
    
    func cellDidIncreaseItem(cell: CartItemTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell),
           let items = cart?.items, indexPath.row < items.count {
            let item = items[indexPath.row]
            cart?.addItem(item.product)
            updateTotalPrice()
            tableView.reloadData()
        }
    }
    
}

extension CartViewController: CartHeaderTableViewCellDelegate {
    
    func cartHeaderDidTapEditAddress() {
        guard customer != nil else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        guard Defaults[\.role] != "doctor" else {
            return
        }
        
        self.showProfile()
    }
    
    func cartHeaderApplyPromoCode(codeID: String) {
        
        APIProduct.getPromoCode(code: codeID) { response in
        
            ProgressHUD.dismiss()
            
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CartHeaderTableViewCell
            if response?.promo_codes?.count ?? 0 > 0 {
                let promocode = (response?.promo_codes?.first)! as Promo_codes
                
                self.promoCodeID = promocode.id ?? 0
                
                if promocode.code == codeID {
                    self.selectedPromoCode = promocode
                    self.rendorPromoCode(promocode)
                    
                } else {
                    cell.rendorPromoCode(isValid: false, discount: 0, promoCode: Promo_codes())
                }
                self.tableView.reloadData()
            } else {
                cell.rendorPromoCode(isValid: false, discount: 0, promoCode: Promo_codes())
            
            }
            self.tableView.reloadData()
            self.updateTotalPrice()
            
        }.request()
        
    }
    
    func rendorPromoCode(_ promocode:Promo_codes) {
        self.promoCodeID = promocode.id ?? 0
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CartHeaderTableViewCell
        var promodiscount = 0.0
        if promocode.discount_type == "percent" {
            let total = self.cart?.calculateTotalPriceInSatang().satangToBaht() ?? 0
            promodiscount =  (total * Double(promocode.discount_value ?? "1")!) / 100
        } else {
            promodiscount = Double(promocode.discount_value ?? "0")!
        }
        cell.rendorPromoCode(isValid: true, discount: promodiscount, promoCode: promocode)
        
        self.updateTotalPrice()
    }
    
//    private func showProfile() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        viewController.showLogout = false
//        viewController.delegate = self
//        viewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
    
}

extension CartViewController: ProfileViewControllerDelegate {
    
    func profileDidSave() {
        customer = CustomerManager.sharedInstance.customer
    }
    
}

extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard case .item = Section(rawValue: section), cart?.items.isEmpty == false || !currentCart else {
            return 0
        }
        
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard case .item = Section(rawValue: section), cart?.items.isEmpty == false || !currentCart else {
            return nil
        }
        
        let view = UIView()
        view.backgroundColor = UIColor.backgroundColor
        
        let headerLabel = UILabel()
        headerLabel.text = "สินค้า"
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = FontSize.h2.bold()
        view.addSubview(headerLabel)
        
        if currentCart {
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: view.topAnchor),
                headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                headerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            let addProductButton = Button(frame: CGRect.zero, radius: 20)
            addProductButton.tintColor = UIColor.blossomPrimary3
            addProductButton.backgroundColor = UIColor.backgroundColor
            addProductButton.layer.borderWidth = 1.0
            addProductButton.layer.borderColor = UIColor.blossomPrimary3.cgColor
            addProductButton.setTitle("+ เพิ่มสินค้า", for: .normal)
            addProductButton.translatesAutoresizingMaskIntoConstraints = false
            addProductButton.addTarget(self, action: #selector(CartViewController.addMoreProduct), for: .touchUpInside)
            view.addSubview(addProductButton)
            
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: view.topAnchor),
                headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                headerLabel.trailingAnchor.constraint(equalTo: addProductButton.leadingAnchor),
                headerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                addProductButton.topAnchor.constraint(equalTo: view.topAnchor),
                addProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                addProductButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                addProductButton.widthAnchor.constraint(equalToConstant: 100)
            ])
        }
        
        return view
        
    }
    
}
