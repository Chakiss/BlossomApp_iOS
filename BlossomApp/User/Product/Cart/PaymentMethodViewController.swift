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

    static func initializeInstance(cart: Cart) -> PaymentMethodViewController {
        let controller: PaymentMethodViewController = PaymentMethodViewController(nibName: "PaymentMethodViewController", bundle: Bundle.main)
        controller.cart = cart
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.backgroundColor
        qrPaymentButton.addConerRadiusAndShadow()
        creditCardPaymentButton.addConerRadiusAndShadow()
        qrPaymentButton.backgroundColor = .white
        creditCardPaymentButton.backgroundColor = .white
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
            "amount": Int(Double(amount) ?? 0),
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
            
            debugPrint("result \(result)")
        }
        
    }
    
    @IBAction func creditCardPayment(_ sender: Any) {
//        mockPaymentSuccess()
        let publicKey = "pkey_test_5mmq1gnwqw4n78r3sil"
        let creditCardView = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardView.preferredPrimaryColor = UIColor.blossomPrimary
        creditCardView.preferredSecondaryColor = UIColor.blossomDarkGray
        creditCardView.delegate = self
        creditCardView.handleErrors = true
        present(creditCardView, animated: true, completion: nil)
    }
    
    private func mockPaymentSuccess() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .orderList
            appDelegate.handleDeeplinking()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    private func updateOrderPayment(omise: OmisePaymentResponse) {
        ProgressHUD.show()
        let paidAt = omise.paidAt ?? ""
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: paidAt) ?? Date()
        let dateString = String.dateFormat(date, format: "dd/MM/yyyy")
        let timeString = String.dateFormat(date, format: "HH:mm")

        APIProduct.updateOrderPayment(orderID: cart?.purchaseOrder?.id ?? 0, omiseID: omise.id ?? "", date: dateString, time: timeString) { [weak self] result in
            ProgressHUD.dismiss()
            guard result else {
                self?.showAlertDialogue(title: "ไม่สามารถอัพเดตสถานะคำสั่งซื้อได้", message: "กรุณาแจ้งเจ้าหน้าที่ และบันทึกหน้าจอนี้\n(Omise: \(omise.id ?? ""))", completion: {
                })
                return
            }
            self?.gotoOrderList()
        }.request()
    }
    
    private func gotoOrderList() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deeplinking = .orderList
            appDelegate.handleDeeplinking()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PaymentMethodViewController : CreditCardFormViewControllerDelegate {
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        ProgressHUD.show()
        APIProduct.chargeCreditCard(amountSatang: cart?.calculateTotalPriceInSatang() ?? 0, token: token.id) { [weak self, weak controller] response in
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
