//
//  UIViewController+Additions.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit

extension UIViewController {
    
    func showError(title: String = "ผิดพลาด", message: String) {
        
        let errorAlertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(errorAlertView, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            errorAlertView.dismiss(animated: true, completion: nil)
        }

    }
    
    func showAlertDialogue(title: String?, message: String, completion: @escaping (() -> Void)) {
        
        let confirmAlertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        confirmAlertView.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
            completion()
        }))
            
        self.present(confirmAlertView, animated: true)

    }

    func showConfirmDialogue(title: String?, message: String, completion: @escaping (() -> Void)) {
        
        let confirmAlertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        confirmAlertView.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: nil))
        confirmAlertView.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: { action in
            completion()
        }))
            
        self.present(confirmAlertView, animated: true)

    }

}
