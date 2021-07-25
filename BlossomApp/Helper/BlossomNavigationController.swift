//
//  BlossomNavigationController.swift
//  BlossomApp
//
//  Created by nim on 25/7/2564 BE.
//

import UIKit

class BlossomNavigationController: UINavigationController {
    
    private func setupAppearance(rootViewController: UIViewController?) {
        view.tintColor = .white
        let appearance = navigationItem.standardAppearance ?? UINavigationBarAppearance(idiom: .phone)
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { (context) in
            context.cgContext.setFillColor(UIColor.blossomPrimary3.cgColor)
            context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        }
        appearance.shadowImage = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
            .withRenderingMode(.alwaysTemplate)
        appearance.shadowColor = .clear
        rootViewController?.navigationItem.standardAppearance = appearance
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance(rootViewController: viewControllers.first)
    }
    
}
