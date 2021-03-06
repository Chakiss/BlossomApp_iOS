//
//  MedicineListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import SafariServices

class MedicineListViewController: UIViewController {
    
    //private let tableView = UITableView(frame: .zero, style: .plain)

    
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    private var orders: [Order] = []
    private var page: Int = 1
    private var loading: Bool = false
    private var hasEnded: Bool = false
    
    var shouldHandleDeeplink: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundColor
        setupTableView()
        
        let backButton = UIBarButtonItem(title: "ใบสั่งยา", style: .plain, target: self, action: nil)
        self.parent?.navigationItem.backBarButtonItem = backButton
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //if orders.isEmpty {
            refreshList()
        //}
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        refreshList()
    }
    
    private func setupTableView() {
//        tableView.register(OrderItemTableViewCell.self, forCellReuseIdentifier: "OrderItemTableViewCell")
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//        NSLayoutConstraint.activate([
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func refreshList() {
        //page = 1
        orders.removeAll()
        getList()
    }
    
    private func getList() {
        
        guard let referenceShipnityID = CustomerManager.sharedInstance.customer?.referenceShipnityID else {
            return
        }
        
        guard !loading else {
            return
        }
        
        if !refreshControl.isRefreshing {
            ProgressHUD.show()
        }
        
        loading = true
        
        APIProduct.getOrderByID(shipnityID: referenceShipnityID) { response in
        
            ProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
            self.loading = false

            guard let response = response else {
                return
            }
            
            //self?.page += 1
            let newData = response.orders ?? []
            //self?.hasEnded = newData.isEmpty
            self.orders.append(contentsOf: newData)
            self.tableView.reloadData()
            

        }.request()
        
    }

}

extension MedicineListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemTableViewCell") as? OrderItemTableViewCell,
              indexPath.row < orders.count else {
            return UITableViewCell()
        }
        
        let order = orders[indexPath.row]
        let paidAt = order.createdAt ?? ""
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: paidAt) ?? Date()
        let title = "Order วันที่ \(String.dateFormat(date, format: "dd/MM/yyyy"))"
        cell.setOrder(title: title, price: Double(order.price ?? "") ?? 0, paid: order.paid == true , address: order.address ?? "")
                
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let order = orders[indexPath.row]
        
        if order.paid == true {
            if let url = URL(string: "https://track.shipnity.com/\(order.slug ?? "")") {
                let webview = SFSafariViewController(url: url)
                self.present(webview, animated: true, completion: nil)
            }
        } else {
            let viewController = CartViewController.initializeInstance(cart: CartManager.shared.convertOrder(order), currentCart: false, customer: CustomerManager.sharedInstance.customer, prescriptDelegate: nil)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if indexPath.row > orders.count-5 && !hasEnded {
//            getList()
//        }
        
    }
    
}

extension MedicineListViewController: UpdateCartViewControllerDelegate {
    
    func cartDidUpdate(order: Order) {
        
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else {
            return
        }
        
        orders.replaceSubrange(index..<index+1, with: [order])
        tableView.reloadData()
        
    }
    
}

extension MedicineListViewController: DeeplinkingHandler {
    
    func handleDeeplink() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deeplinking = appDelegate.deeplinking {
            switch deeplinking {
            case .orderList:
                refreshList()
            default:
                break
            }
        }
    }
    
}
