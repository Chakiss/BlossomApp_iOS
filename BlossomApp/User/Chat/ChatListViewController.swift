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
   
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        self.customer = CustomerManager.sharedInstance.customer

        Request.dialogs(with: Paginator.limit(100, skip: 0), extendedRequest: nil, successBlock: { (dialogs, usersIDs, paginator) in
            self.dialogList = dialogs
            self.dialogList.sort(by: { ($0.lastMessageDate ?? Date()).compare($1.lastMessageDate ?? Date()) == ComparisonResult.orderedDescending })
            self.tableView.reloadData()
           
            
        }) { (error) in
            print(error)
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
        cell.getImageDoctor()
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
