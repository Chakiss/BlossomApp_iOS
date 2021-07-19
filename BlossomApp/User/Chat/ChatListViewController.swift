//
//  ChatListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import ConnectyCube
import Firebase

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDelegate{

    var user: Firebase.User!
    var customer: Customer?
    
    var dialogList:[ChatDialog] = []
    
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
        self.title = "แชท"
        
        
        CustomerManager().getCustomer { customer in
            self.customer = customer
            let userID = UInt(self.customer?.referenceConnectyCubeID ?? "0")
            let chat = Chat.instance
            chat.addDelegate(self)
            chat.connect(withUserID: userID!, password: "123456") { error in
               print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        Request.dialogs(with: Paginator.limit(100, skip: 0), extendedRequest: nil, successBlock: { (dialogs, usersIDs, paginator) in
            self.dialogList = dialogs
            self.dialogList.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
            self.tableView.reloadData()
           
            
        }) { (error) in
            
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
       
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "DailogCell", for: indexPath) as! DailogCell
        //cell.nameLabel?.text = dailog.name
        //cell.messageLabel?.text = dailog.lastMessageText
        //cell.timeLabel?.text = dailog.lastMessageDate?.timeAgoDisplay()
        
        let dialog = self.dialogList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell", for: indexPath) as! DialogCell
        //let dialog: ChatDialog = ChatApp.dialogs.sortedData.object(indexPath)!
        //cell.setTitle(title: dialog.name, imageUrl: "")
        cell.titleLabel.text = dialog.name
        cell.setLastMessageText(lastMessageText: dialog.lastMessageText, date: dialog.updatedAt!, unreadMessageCount:dialog.unreadMessagesCount)
        
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
