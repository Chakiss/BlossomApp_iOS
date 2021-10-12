//
//  ChatListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import ConnectyCube
import Firebase
import SwiftyUserDefaults

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var user: Firebase.User!
    var customer: Customer?
    
    var dialogList:[ChatDialog] = []
    
    var deeplinkID: String = ""
    
    private var channelList: [Channel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "แชท"
   
        let inboxIcon = UIBarButtonItem(image: UIImage(systemName: "bell.badge"), style: .plain, target: self, action: #selector(gotoInbox))
        self.navigationItem.rightBarButtonItem = inboxIcon
        
        
        let contactIcon = UIBarButtonItem(title: "ติดต่อ Admin", style: .plain, target: self, action:
        #selector(contactAdmin))
        self.navigationItem.leftBarButtonItem = contactIcon
    }
    
    @objc
    private func gotoInbox() {
        let inboxView = InboxTableViewController(style: .plain)
        inboxView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(inboxView, animated: true)
    }
    
    @objc
    func contactAdmin() {
        UIApplication.shared.open(URL(string: "https://lin.ee/iYHm3As")!, options: [:], completionHandler: nil)
        /*
        showAlertDialogue(title: "ติดต่อ", message: "กล่องข้อความของ admin จะปรากฏขึ้น") {
            let dialog = ChatDialog(dialogID: nil, type: .private)
            dialog.occupantIDs = [4663567]  // an ID of opponent
            self.deeplinkID = "4663567"
            Request.createDialog(dialog, successBlock: { (dialog) in
                self.viewWillAppear(true)
            }) { (error) in

            }
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        let user = Auth.auth().currentUser
        if user == nil {
            return
        }
        if Defaults[\.role] == "customer"{
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            self.customer = customer
        }
        
       
                
        db.collection("channels")
            .whereField("customerReference", isEqualTo: customer?.documentReference as Any)
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                
                guard (snapshot?.documents) != nil else {
                    print("No documents")
                    return
                }
                let channels = (snapshot?.documents.map { queryDocumentSnapshot -> Channel  in
                    let data = queryDocumentSnapshot.data()
                    let doctorRef = data["doctorReference"]  as? DocumentReference ?? nil
                    let cusRef = data["customerReference"]  as? DocumentReference ?? nil
                    let createdAt = data["createdAt"]  as? Timestamp ?? nil
                    let updatedAt = data["updatedAt"]  as? Timestamp ?? nil
                    
                    var channel = Channel(id: queryDocumentSnapshot.documentID)
                    channel.doctorReference = doctorRef
                    channel.customerReference = cusRef
                    channel.createdAt = createdAt
                    channel.updateAt = updatedAt
                
                    return channel
                })
                
                guard channels != nil else {
                    return
                }
                
                self.channelList = channels ?? []
                self.tableView.reloadData()
            
            }
        

    
    }
    
    func checkDeepLink() {
        if !deeplinkID.isEmpty {
            let dialog = self.dialogList.filter{ $0.recipientID == Int(deeplinkID) }.first
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MessageingViewController") as! MessageingViewController
            viewController.chatdialog = dialog
            viewController.customer = self.customer
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            
            deeplinkID = ""
            
        
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let channel = self.channelList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell", for: indexPath) as! DialogCell
        cell.channel = channel
        cell.getImageDoctor()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let cell = tableView.cellForRow(at: indexPath) as! DialogCell
        
        let channelSelected = cell.channel
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MessageingViewController") as! MessageingViewController
//        viewController.chatdialog = dialog
        viewController.channelMessage = channelSelected
        viewController.customer = self.customer
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
