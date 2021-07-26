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

class PaymentMethodViewController: UIViewController {

    @IBOutlet weak var qrPaymentButton: UIButton!
    @IBOutlet weak var creditCardPaymentButton: UIButton!
    
    private var cart: Cart?
    private var omiseResponse: OmisePaymentResponse?

    static func initializeInstance(cart: Cart) -> PaymentMethodViewController {
        let controller: PaymentMethodViewController = PaymentMethodViewController(nibName: "PaymentMethodViewController", bundle: Bundle.main)
        controller.cart = cart
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.backgroundColor
        qrPaymentButton.addConerRadiusAndShadow()
        creditCardPaymentButton.addConerRadiusAndShadow()
        qrPaymentButton.tintColor = UIColor.blossomDarkGray
        creditCardPaymentButton.tintColor = UIColor.blossomDarkGray
        qrPaymentButton.backgroundColor = .white
        creditCardPaymentButton.backgroundColor = .white
        self.title = "เลือกวิธีชำระเงิน"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cart?.id == CartManager.shared.currentCart?.id {
            clearCart()
        }
        
    }
    
    private func clearCart() {
        CartManager.shared.clearCart()
        
        // remove previous view
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeAll(where: { $0 is CartViewController })
        navigationController?.setViewControllers(viewControllers ?? [], animated: false)
    }

    @IBAction func qrPayment(_ sender: Any) {
//        mockPaymentSuccess()
        let amount = cart?.purchaseOrder?.price ?? ""
        let payload: [String: Any] = [
            "amount": Double(amount) ?? 0,
            "orderID": "\(cart?.purchaseOrder?.id ?? 0)",
            "channel": "shipnity"
        ]
        debugPrint("generatePromptPayQR \(payload)")
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
            
            if let cart = self?.cart {
                let qrView = QRPaymentViewController.initializeInstance(cart: cart, qr: qr.replacingOccurrences(of: "data:image/png;base64,", with: ""))
                qrView.delegate = self
                self?.navigationController?.pushViewController(qrView, animated: true)
            }
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
        ProgressHUD.show()
        let orderID = cart?.purchaseOrder?.id ?? 0

        APIProduct.updateOrderPayment(orderID: orderID) { [weak self] result in
            guard result else {
                ProgressHUD.dismiss()
                self?.showAlertDialogue(title: "ไม่สามารถอัพเดตสถานะคำสั่งซื้อได้", message: "กรุณาแจ้งเจ้าหน้าที่ และบันทึกหน้าจอนี้\n(Omise: \(omiseID ?? "n/a"))", completion: {
                })
                return
            }
            
            APIProduct.updateOrderNote(orderID: orderID, note: omiseID ?? "") { [weak self] response in
                ProgressHUD.dismiss()
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
        ProgressHUD.show()
        APIProduct.chargeCreditCard(orderID: cart?.purchaseOrder?.id ?? 0, amountSatang: cart?.calculateTotalPriceInSatang() ?? 0, token: token.id) { [weak self, weak controller] response in
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
        let publicKey = "pkey_test_5mmq1gnwqw4n78r3sil"
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
        gotoOrderList()
    }
    
}
