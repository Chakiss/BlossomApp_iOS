//
//  OrderItemTableViewCell.swift
//  BlossomApp
//
//  Created by nim on 26/7/2564 BE.
//

import UIKit

class OrderItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statusButton: Button!
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupView()
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        
        selectionStyle = .none
        backgroundColor = .backgroundColor
        
//        let view = UIView()
//        view.backgroundColor = .white
        view.addConerRadiusAndShadow()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(view)

//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
        
//        let textStack = UIStackView()
//        textStack.axis = .vertical
        
//        textStack.translatesAutoresizingMaskIntoConstraints = true
//        stackView.addArrangedSubview(textStack)

        orderLabel.font = FontSize.body.bold()
//        orderLabel.translatesAutoresizingMaskIntoConstraints = false
//        textStack.addArrangedSubview(orderLabel)
//        textStack.addArrangedSubview(UIView())

        addressLabel.font = FontSize.small.regular()
//        addressLabel.numberOfLines = 0
//        addressLabel.setContentHuggingPriority(.required, for: .vertical)
//        addressLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        addressLabel.translatesAutoresizingMaskIntoConstraints = true
//        textStack.addArrangedSubview(addressLabel)
//
        totalLabel.font = FontSize.body2.regular()
//        totalLabel.setContentHuggingPriority(.required, for: .vertical)
//        totalLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        totalLabel.translatesAutoresizingMaskIntoConstraints = false
//        textStack.addArrangedSubview(totalLabel)
//
//        let buttonView = UIView()
//        buttonView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.addArrangedSubview(buttonView)
        
//        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.roundCorner(radius: 20)
//        buttonView.addSubview(statusButton)

//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
//            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
//            view.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
//            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
//            stackView.heightAnchor.constraint(equalToConstant: 80),
//            statusButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 10),
//            statusButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -10),
//            statusButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
//            statusButton.widthAnchor.constraint(equalToConstant: 100),
//            statusButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
        
    }
    
    func setOrder(title: String, price: Double, paid: Bool, address: String) {
        orderLabel.text = title
        addressLabel.text = address
        totalLabel.text = "ราคา \(price.toAmountText()) บาท"
        statusButton.backgroundColor = paid ? UIColor.blossomGreen : UIColor.red.withAlphaComponent(0.7)
        let statusText = paid ? "ชำระเงินแล้ว" : "ยังไม่ชำระ"
        statusButton.setTitle(statusText, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
