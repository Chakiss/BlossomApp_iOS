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
    private var appointmentOrder: String?
    
    private weak var db = Firestore.firestore()

    static func initializeInstance(cart: Cart?, appointmentOrder: String?, qr: String) -> QRPaymentViewController {
        let controller: QRPaymentViewController = QRPaymentViewController(nibName: "QRPaymentViewController", bundle: Bundle.main)
        controller.hidesBottomBarWhenPushed = true
        controller.cart = cart
        controller.qr = qr
        controller.appointmentOrder = appointmentOrder
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
        
        checkPaymentSuccess()
    }

//    @IBAction func nextAction(_ sender: Any) {
//        checkPaymentSuccess()
//    }
    
    private func checkPaymentSuccess() {
        
        let orderID = cart?.purchaseOrder?.id != nil ? "\(cart!.purchaseOrder!.id!)" : appointmentOrder ?? ""
        ProgressHUD.show()
        if cart?.purchaseOrder?.id != nil  {
            db?.collection("shipnity_orders").document(orderID).addSnapshotListener({ [weak self] result, error in
                ProgressHUD.dismiss()
                let data = result?.data()
                let isPaid = data?["isPaid"] as? Bool ?? false
                if isPaid == true {
                    self?.updateOrderPayment(paidAt: Date(), orderID:orderID)
                }
            })
        } else {
            db?.collection("orders").document(orderID).addSnapshotListener({ [weak self] result, error in
                ProgressHUD.dismiss()
                let data = result?.data()
                let isPaid = data?["status"] as? String ?? ""
                if isPaid == "paid" {
                    self?.updateOrderPayment(paidAt: Date(), orderID:orderID)
                }
            })
        }
        
    }
    
    private func updateOrderPayment(paidAt date: Date, orderID: String? = nil) {
        
       
        ProgressHUD.show()
        //let orderID = cart?.purchaseOrder?.id ?? 0
        let orderIBNumner = Int(orderID ?? "0")!
        APIProduct.updateOrderPayment(bank:"prompt_pay",orderID: orderIBNumner) { [weak self] result in
            guard result else {
                ProgressHUD.dismiss()
                self?.showAlertDialogue(title: "ไม่สามารถอัพเดตสถานะคำสั่งซื้อได้", message: "กรุณาแจ้งเจ้าหน้าที่ และบันทึกหน้าจอนี้\n(Omise: \(orderID ?? "n/a"))", completion: {
                })
                return
            }
            
            APIProduct.updateOrderNote(orderID: orderIBNumner, note: orderID ?? "") { [weak self] response in
                ProgressHUD.dismiss()
                
                self?.delegate?.qrPaymentComplete()
                
            }.request()
            
        }.request()
    }
   
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "บันทึกรูปแล้ว", message: "โปรดนำQRcode นี้ชำระเงิน mobile application ของท่าน", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
