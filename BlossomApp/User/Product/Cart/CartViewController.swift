//
//  CartViewController.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit

class CartViewController: UIViewController {
    
    enum Section: Int {
        case header = 0
        case item
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    
    private var cartHeaderModel: CartHeaderTableViewCell.Model?
    private var cart: Cart?
    private var currentCart: Bool = true
    
    static func initializeInstance(cart: Cart, currentCart: Bool = true) -> CartViewController {
        let controller: CartViewController = CartViewController(nibName: "CartViewController", bundle: Bundle.main)
        controller.cart = cart
        controller.currentCart = currentCart
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    private func setupView() {
        self.checkoutButton.superview?.backgroundColor = UIColor.backgroundColor
        self.checkoutButton.backgroundColor = UIColor.blossomPrimary
        self.checkoutButton.roundCorner(radius: 22)
        self.checkoutButton.setTitle("ชำระเงิน", for: .normal)
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
        
        let model = CartHeaderTableViewCell.Model(
            dateString: String.today(),
            priceText: "",
            addressText: CustomerManager.sharedInstance.customer?.address?.address ?? "-"
        )
        self.cartHeaderModel = model
        updateTotalPrice()
        tableView.reloadData()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "ตะกร้าสินค้า"
                
        setupView()
        setupTableView()
        
    }

    private func updateTotalPrice() {
        let total = cart?.calculateTotalPriceInSatang().satangToBaht() ?? 0
        let totalText = total.toAmountText()
        self.cartHeaderModel?.priceText = totalText
        checkoutButton.isEnabled = cart?.items.count ?? 0 > 0
        checkoutButton.alpha = checkoutButton.isEnabled ? 1.0 : 0.5
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
        debugPrint(" add more product ")
    }
    
    private func createOrder() {
        
        guard let customer = CustomerManager.sharedInstance.customer else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        
        guard let address = customer.address?.address, !address.isEmpty else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาระบุที่อยู่จัดส่ง") { [weak self] in
                self?.showProfile()
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
                                  shippingType: "EMS",
                                  shippingFee: 0,
                                  orderDiscount: 0,
                                  purchasesAttributes: cart?.getPurcahseAttributes() ?? [])
        ProgressHUD.show()
        APIProduct.createOrder(po: CreateOrderRequest(order: order)) { [weak self] response in
            ProgressHUD.dismiss()
            guard let response = response,
                  let order = response.order else {
                self?.showAlertDialogue(title: "ผิดพลาด", message: "ไม่สามารถส่งคำสั่งซื้อได้ในขณะนี้", completion: {
                })
                return
            }
            self?.cart?.updatePO(order)
            self?.gotoPaymentMethod()
        }.request()
    }
    
    private func updateOrder() {
        gotoPaymentMethod()
    }
    
    private func gotoPaymentMethod() {
        
        guard let cart = cart else {
            return
        }
        
        let paymentMethodViewController = PaymentMethodViewController.initializeInstance(cart: cart)
        self.navigationController?.pushViewController(paymentMethodViewController, animated: true)
        
    }
    
    @IBAction func checkoutCart(_ sender: Any) {
        if currentCart {
            createOrder()
        } else {
            updateOrder()
        }
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
        guard CustomerManager.sharedInstance.customer != nil else {
            showAlertDialogue(title: "ไม่สามารถดำเนินการได้", message: "กรุณาเข้าสู่ระบบ") { [weak self] in
                self?.showLoginView()
            }
            return
        }
        showProfile()
    }
    
    private func showProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController.showLogout = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard case .item = Section(rawValue: section), cart?.items.isEmpty == false else {
            return 0
        }
        
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard case .item = Section(rawValue: section), cart?.items.isEmpty == false else {
            return nil
        }
        
        let view = UIView()
        view.backgroundColor = UIColor.backgroundColor
        
        let headerLabel = UILabel()
        headerLabel.text = "สินค้า"
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        if currentCart {
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: view.topAnchor),
                headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                headerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            let addProductButton = UIButton(type: .system)
            addProductButton.tintColor = UIColor.blossomPrimary
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
