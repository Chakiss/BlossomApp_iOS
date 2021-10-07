//
//  BankTransferViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 2/8/2564 BE.
//

import UIKit
import Firebase

class BankTransferViewController: UIViewController {

    static func initializeInstance() -> BankTransferViewController {
        let controller: BankTransferViewController = BankTransferViewController(nibName: "BankTransferViewController", bundle: Bundle.main)
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    
    var cart: Cart?
    
    lazy var functions = Functions.functions()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func updateImage() {
        ImagePickerManager().pickImage(self){ image in
            
            if let imageData = image.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                
                let amount = self.cart?.purchaseOrder?.price ?? ""
                let payload: [String: Any] = [
                    "image": encodeString,
                    "total": Double(amount) ?? 0,
                    "orderID": "\(self.cart?.purchaseOrder?.id ?? 0)",
                    "type": "shipnity"
                ]
                
                ProgressHUD.show()
                self.functions.httpsCallable("app-payments-uploadAndVerifyPayment").call(payload) { result, error in

                    ProgressHUD.dismiss()
                    if error == nil {
                        self.showAlertDialogue(title: "สำเร็จ", message: "กรุณาจอตรวจสอบ", completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        //let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error?.localizedDescription
                        
                        self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: message ?? "", completion: {
                            
                        })
                    }
                }
            }
           
        }
        
        
    }
    
    @IBAction func lineButtonTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://lin.ee/iYHm3As")!, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func copySCBButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string =  "2082364723"
        showAlertDialogue(title: "คัดลอกสำเร็จ", message: "2082364723") {}
    }
    
    @IBAction func copyKbankButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string =  "0408729920"
        
        showAlertDialogue(title: "คัดลอกสำเร็จ", message: "0408729920") {}
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
