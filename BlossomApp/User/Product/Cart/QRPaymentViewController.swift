//
//  QRPaymentViewController.swift
//  BlossomApp
//
//  Created by nim on 26/7/2564 BE.
//

import UIKit
import Firebase

protocol QRPaymentViewControllerDelegate: AnyObject {
    func qrPaymentComplete()
}

class QRPaymentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!

    weak var delegate: QRPaymentViewControllerDelegate?
    
    private var cart: Cart?
    private var qr: String = ""
    
    private weak var db = Firestore.firestore()

    static func initializeInstance(cart: Cart, qr: String) -> QRPaymentViewController {
        let controller: QRPaymentViewController = QRPaymentViewController(nibName: "QRPaymentViewController", bundle: Bundle.main)
        controller.hidesBottomBarWhenPushed = true
        controller.cart = cart
        controller.qr = qr
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "QR"
        self.nextButton.roundCorner(radius: 22)
        
        if let imageData = Data(base64Encoded: qr) {
            let image = UIImage(data: imageData)
            self.imageView.image = image
        }
        
    }

    @IBAction func nextAction(_ sender: Any) {
        checkPaymentSuccess()
    }
    
    private func checkPaymentSuccess() {
        
        guard let orderID = cart?.purchaseOrder?.id else {
            return
        }
        
        db?.collection("shipnity_orders").document("\(orderID)").addSnapshotListener({ [weak self] result, error in
            
            guard error == nil || result?.data() != nil else {
                self?.showAlertDialogue(title: "ไม่สามารถชำระเงินด้วย QR ได้", message: "กรุณาลองใหม่ภายหลัง", completion: {
                    
                })
                return
            }
            
            self?.delegate?.qrPaymentComplete()
        })
        
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
