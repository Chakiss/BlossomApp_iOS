//
//  MedicineListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import SafariServices

class MedicineListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private var orders: [Order] = []
    private var page: Int = 1
    private var loading: Bool = false
    private var hasEnded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundColor
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if orders.isEmpty {
            refreshList()
        }
    }
    
    private func setupTableView() {
        tableView.register(OrderItemTableViewCell.self, forCellReuseIdentifier: "OrderItemTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func refreshList() {
        page = 1
        orders.removeAll()
        getList()
    }
    
    private func getList() {
        
        guard let customerPhone = CustomerManager.sharedInstance.customer?.phoneNumber else {
            return
        }
        
        guard !loading else {
            return
        }
        
        if !refreshControl.isRefreshing {
            ProgressHUD.show()
        }
        
        loading = true
        APIProduct.getOrder(term: customerPhone, page: page) { [weak self] response in
            ProgressHUD.dismiss()
            self?.refreshControl.endRefreshing()
            self?.loading = false

            guard let response = response else {
                return
            }
            
            self?.page += 1
            let newData = response.orders ?? []
            self?.hasEnded = newData.isEmpty
            self?.orders.append(contentsOf: newData)
            self?.tableView.reloadData()
            
        }.request()
        
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
        cell.setOrder(title: title, price: Double(order.price ?? "") ?? 0, paid: order.paid == true)
                
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
            let viewController = CartViewController.initializeInstance(cart: CartManager.shared.convertOrder(order), currentCart: false)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row > orders.count-5 && !hasEnded {
            getList()
        }
        
    }
    
}
