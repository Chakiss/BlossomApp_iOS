//
//  PaymentMethodViewController.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit
import FirebaseFunctions
import Firebase
import OmiseSDK
import FirebaseRemoteConfig

struct AppointmentOrder {
    let id: String
    let amount: Int
}

class PaymentMethodViewController: UIViewController {

    @IBOutlet weak var qrPaymentButton: UIButton!
    @IBOutlet weak var creditCardPaymentButton: UIButton!
    @IBOutlet weak var bankTransferButton: UIButton!
    
    private var cart: Cart?
    private var appointmentOrder: AppointmentOrder?
    private var omiseResponse: OmisePaymentResponse?

    var delegate: UpdateCartViewControllerDelegate?
    
    var isBankTransfer:Bool = false

    static func initializeInstance(cart: Cart?, appointmentOrder: AppointmentOrder? = nil) -> PaymentMethodViewController {
        let controller: PaymentMethodViewController = PaymentMethodViewController(nibName: "PaymentMethodViewController", bundle: Bundle.main)
        controller.cart = cart
        controller.appointmentOrder = appointmentOrder
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.backgroundColor
        qrPaymentButton.addConerRadiusAndShadow()
        creditCardPaymentButton.addConerRadiusAndShadow()
        bankTransferButton.addConerRadiusAndShadow()
        qrPaymentButton.tintColor = UIColor.blossomDarkGray
        creditCardPaymentButton.tintColor = UIColor.blossomDarkGray
        bankTransferButton.tintColor = UIColor.blossomDarkGray
        qrPaymentButton.backgroundColor = .white
        creditCardPaymentButton.backgroundColor = .white
        bankTransferButton.backgroundColor = .white
        bankTransferButton.isHidden = true
       
        self.title = "เลือกวิธีชำระเงิน"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBankTransfer == true {
            bankTransferButton.isHidden = false
        }
        if cart?.id == CartManager.shared.currentCart?.id && appointmentOrder == nil {
            clearCart()
        }
        
        
        
        let config = RemoteConfig.remoteConfig()
        let showSCB = config["showSCB"].stringValue
        if showSCB == "no" {
            self.qrPaymentButton.isHidden = true
        } else {
            self.qrPaymentButton.isHidden = false
        }
    }
    
    
    private func clearCart() {
        CartManager.shared.clearCart()
        
        // remove previous view
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeAll(where: { $0 is CartViewController })
        navigationController?.setViewControllers(viewControllers ?? [], animated: false)
    }
    
    @IBAction func bankTransferButtonTapped(_ sender: Any) {
        let bankTeansferView = BankTransferViewController.initializeInstance()
        self.navigationController?.pushViewController(bankTeansferView, animated: true)
    }
    
    
    private func requestQRPayment(payload: [String: Any]) {
        ProgressHUD.show()
        Functions.functions().httpsCallable("app-payments-generatePromptPayQR").call(payload) { [weak self] result, error in
            ProgressHUD.dismiss()
            
            guard error == nil else {
                self?.showAlertDialogue(title: "ไม่สามารถชำระเงินด้วย QR ได้", message: "ERROR: \(error!.localizedDescription)", completion: {
                    
                })
                return
            }
            
            guard let data = result?.data as? [String: Any],
                  let qr = data["image"] as? String else {
                self?.showAlertDialogue(title: "ไม่สามารถชำระเงินด้วย QR ได้", message: "กรุณาลองใหม่ภายหลัง", completion: {
                    
                })
                return
            }
            
            let qrView = QRPaymentViewController.initializeInstance(cart: self?.cart, appointmentOrder: self?.appointmentOrder?.id, qr: qr.replacingOccurrences(of: "data:image/png;base64,", with: ""))
            qrView.delegate = self
            self?.navigationController?.pushViewController(qrView, animated: true)
        }
    }
    
    private func qrPayment(for appointmentOrder: AppointmentOrder) {
        let amount = appointmentOrder.amount
        let payload: [String: Any] = [
            "amount": Double(amount),
            "orderID": appointmentOrder.id,
            "channel": "app"
        ]
        debugPrint("generatePromptPayQR \(payload)")
        requestQRPayment(payload: payload)
    }

    private func qrPayment(for cart: Cart) {
        let amount = cart.purchaseOrder?.price ?? ""
        let payload: [String: Any] = [
            "amount": Double(amount) ?? 0,
            "orderID": "\(cart.purchaseOrder?.id ?? 0)",
            "channel": "shipnity"
        ]
        debugPrint("generatePromptPayQR \(payload)")
        requestQRPayment(payload: payload)
    }

    @IBAction func qrPayment(_ sender: Any) {
        if let cart = cart {
            qrPayment(for: cart)
        } else if let order = appointmentOrder {
            qrPayment(for: order)
        }
    }
    
    @IBAction func creditCardPayment(_ sender: Any) {
        let creditCardView = CreditCardInputViewController()
        creditCardView.delegate = self
        let navigationController = BlossomNavigationController(rootViewController: creditCardView)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    private func mockPaymentSuccess() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .orderList
            appDelegate.handleDeeplinking()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    private func updateOrderPayment(omise: OmisePaymentResponse) {
        self.omiseResponse = omise
        
        let paidAt = omise.paidAt ?? ""
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: paidAt) ?? Date()
        
        guard let authorizeURI = omise.authorizeURI,
              let components = URLComponents(string: "https://www.blossomclinicthailand.com/omise"),
              let url = URL(string: authorizeURI) else {
            updateOrderPayment(paidAt: date, omiseID: omise.id)
            return
        }
        
        let webview = AuthorizingPaymentViewController.makeAuthorizingPaymentViewControllerWithAuthorizedURL(url, expectedReturnURLPatterns: [components], delegate: self)
        let navigationController = BlossomNavigationController(rootViewController: webview)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
        
    }
    
    private func updateOrderPayment(paidAt date: Date, omiseID: String? = nil) {
        
        guard appointmentOrder == nil else {
            delegate?.appointmentOrderSuccess(orderID: appointmentOrder?.id ?? "")
            return
        }
        
        ProgressHUD.show()
        let orderID = cart?.purchaseOrder?.id ?? 0

        APIProduct.updateOrderPayment(bank:"creditcard", orderID: orderID) { [weak self] result in
            guard result else {
                ProgressHUD.dismiss()
                self?.showAlertDialogue(title: "ไม่สามารถอัพเดตสถานะคำสั่งซื้อได้", message: "กรุณาแจ้งเจ้าหน้าที่ และบันทึกหน้าจอนี้\n(Omise: \(omiseID ?? "n/a"))", completion: {
                })
                return
            }
            
            APIProduct.updateOrderNote(orderID: orderID, note: omiseID ?? "") { [weak self] response in
                ProgressHUD.dismiss()
                
                if let order = response?.order {
                    self?.delegate?.cartDidUpdate(order: order)
                }
                
                self?.gotoOrderList()
            }.request()
            
        }.request()
    }
    
    private func gotoOrderList() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .orderList
            appDelegate.handleDeeplinking()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }

}

extension PaymentMethodViewController : CreditCardFormViewControllerDelegate {
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        
        let orderID = appointmentOrder != nil ? "\(appointmentOrder!.id)" : "\(cart?.purchaseOrder?.id ?? 0)"
        let amountSatang = appointmentOrder != nil ? appointmentOrder!.amount*100 : (cart?.calculateTotalPriceInSatang() ?? 0) + (cart?.shippingFeeInSatang() ?? 0) 
        let ref = appointmentOrder != nil ? "1Z\(appointmentOrder!.id)" : "2Z\(cart?.purchaseOrder?.id ?? 0)"
        ProgressHUD.show()
        APIProduct.chargeCreditCard(orderID: orderID, amountSatang: amountSatang, token: token.id, ref: ref) { [weak self, weak controller] response in
            ProgressHUD.dismiss()
            guard let response = response else {
                controller?.showAlertDialogue(title: "ไม่สามารถชำระเงินด้วยบัตรเครดิตได้", message: "กรุณาลองใหม่ภายหลัง", completion: {
                })
                return
            }
            
            guard response.failureMessage == nil else {
                controller?.showAlertDialogue(title: "ไม่สามารถชำระเงินด้วยบัตรเครดิตได้", message: "กรุณาลองใหม่ภายหลัง\n\n(\(response.failureMessage!))", completion: {
                })
                return
            }
            
            self?.dismiss(animated: true, completion: nil)
            self?.updateOrderPayment(omise: response)
        }.request()
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        showAlertDialogue(title: "ไม่สามารถชำระเงินได้", message: error.localizedDescription) {
            
        }
    }
    
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PaymentMethodViewController : AuthorizingPaymentViewControllerDelegate {
    
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        dismiss(animated: true, completion: nil)
        
        guard let omise = self.omiseResponse else {
            return
        }
        
        ProgressHUD.show()
        APIProduct.getChargeCreditCard(chargeID: omise.id ?? "") {[weak self] omiseResponse in
            ProgressHUD.dismiss()
            guard let response = omiseResponse else {
                self?.showAlertDialogue(title: "ไม่สามารถอัพเดตสถานะคำสั่งซื้อได้", message: "กรุณาแจ้งเจ้าหน้าที่ และบันทึกหน้าจอนี้\n(Omise: \(omise.id ?? "n/a"))", completion: {
                })
                return
            }
            let paidAt = response.paidAt ?? ""
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: paidAt) ?? Date()
            self?.updateOrderPayment(paidAt: date, omiseID: response.id)
        }.request()
        
    }
    
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

fileprivate class CreditCardInputViewController: UIViewController {
    
    weak var delegate: CreditCardFormViewControllerDelegate?
    
    private lazy var omiseView: CreditCardFormViewController = {
        let publicKey = "pkey_5ngemrt9grz0ail7cj0"
        let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardView.preferredPrimaryColor = UIColor.blossomPrimary
        creditCardView.preferredSecondaryColor = UIColor.blossomLightGray
        creditCardView.delegate = self
        creditCardView.handleErrors = true
        return creditCardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "กรอกข้อมูลบัตรเครดิต"
        self.view.backgroundColor = UIColor.backgroundColor
        omiseView.view.translatesAutoresizingMaskIntoConstraints = false
        omiseView.view.frame = view.bounds
        omiseView.view.backgroundColor = .clear
        omiseView.view.tintColor = UIColor.blossomPrimary3
        
        view.addSubview(omiseView.view)
        addChild(omiseView)
        
        if let scrollView = omiseView.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let button = scrollView.subviews.first(where: { $0 is UIButton }) as? UIButton {
            button.backgroundColor = UIColor.blossomPrimary
        }
        
        NSLayoutConstraint.activate([
            omiseView.view.topAnchor.constraint(equalTo: view.topAnchor),
            omiseView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            omiseView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            omiseView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissOmise))

    }
    
    @objc private func dismissOmise() {
        delegate?.creditCardFormViewControllerDidCancel(omiseView)
    }

}

extension CreditCardInputViewController : CreditCardFormViewControllerDelegate {
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        delegate?.creditCardFormViewController(controller, didSucceedWithToken: token)
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        delegate?.creditCardFormViewController(controller, didFailWithError: error)
    }
    
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        delegate?.creditCardFormViewControllerDidCancel(controller)
    }
    
}

extension PaymentMethodViewController: QRPaymentViewControllerDelegate {
    
    func qrPaymentComplete() {
        if cart != nil {
            gotoOrderList()
        } else {
            delegate?.appointmentOrderSuccess(orderID: appointmentOrder?.id ?? "")
        }
    }
    
}
