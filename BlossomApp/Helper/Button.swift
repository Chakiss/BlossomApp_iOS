//
//  Button.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

import UIKit

class Button: UIButton {
    
    private let radius: CGFloat
    
    required init?(coder: NSCoder) {
        self.radius = 15
        super.init(coder: coder)
        setupButton()
    }
    
    private override init(frame: CGRect) {
        self.radius = 15
        super.init(frame: frame)
        setupButton()
    }
    
    init(frame: CGRect, radius: CGFloat) {
        self.radius = radius
        super.init(frame: frame)
        setupButton()
    }
    
    convenience init(radius: CGFloat = 15) {
        self.init(frame: CGRect.zero, radius: radius)
        setupButton()
    }
    
    private func setupButton() {
        self.layer.cornerRadius = radius
        self.backgroundColor = UIColor.blossomPrimary
        self.titleLabel?.font = FontSize.body2.regular()
        startAnimatingPressActions()
    }
    
}

extension UIButton {
    
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpOutside])
        addTarget(self, action: #selector(animateDownAndUp), for: [.primaryActionTriggered, .touchUpInside])
    }
    
    @objc private func animateDownAndUp(sender: UIButton) {
        animateDown(sender: sender)
        perform(#selector(animateUp), with: self, afterDelay: 0.4)
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
                        button.transform = transform
            }, completion: nil)
    }
    
}
