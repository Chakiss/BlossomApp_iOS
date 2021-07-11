//
//  PaymentMethodViewController.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit

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
        mockPaymentSuccess()
    }
    
    @IBAction func creditCardPayment(_ sender: Any) {
        mockPaymentSuccess()
    }
    
    private func mockPaymentSuccess() {
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
