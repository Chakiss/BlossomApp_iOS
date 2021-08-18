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

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDelegate{

    var user: Firebase.User!
    var customer: Customer?
    
    var dialogList:[ChatDialog] = []
    
    var deeplinkID: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    func chatDidConnect() {
        print("chatDidConnect")
    }
    
    func chatDidReconnect() {
        print("chatDidReconnect")
    }
    
    func chatDidDisconnectWithError(_ error: Error) {
        print(error)
        print("chatDidReconnect")
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        print(error)
        print("chatDidReconnect")
    }
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
        showAlertDialogue(title: "ติดต่อ", message: "กล่องข้อความของ admin จะปรากฏขึ้น") {
            let dialog = ChatDialog(dialogID: nil, type: .private)
            dialog.occupantIDs = [4663567]  // an ID of opponent
            self.deeplinkID = "4663567"
            Request.createDialog(dialog, successBlock: { (dialog) in
                self.viewWillAppear(true)
            }) { (error) in

            }
        }
        
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
        
        Request.dialogs(with: Paginator.limit(100, skip: 0), extendedRequest: nil, successBlock: { (dialogs, usersIDs, paginator) in
            self.dialogList = dialogs
            self.dialogList.sort(by: { ($0.lastMessageDate ?? Date()).compare($1.lastMessageDate ?? Date()) == ComparisonResult.orderedDescending })
           
            self.checkDeepLink()
            self.tableView.reloadData()
           
            
        }) { (error) in
            print(error)
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
        return dialogList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let dialog = self.dialogList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell", for: indexPath) as! DialogCell
        //let dialog: ChatDialog = ChatApp.dialogs.sortedData.object(indexPath)!
        //cell.setTitle(title: dialog.name, imageUrl: "")
        cell.titleLabel.text = dialog.name
        cell.setLastMessageText(lastMessageText: dialog.lastMessageText, date: dialog.updatedAt!, unreadMessageCount:dialog.unreadMessagesCount)
        cell.dialog = dialog
        //cell.getImageDoctor()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dialog = self.dialogList[indexPath.row]
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MessageingViewController") as! MessageingViewController
        viewController.chatdialog = dialog
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
