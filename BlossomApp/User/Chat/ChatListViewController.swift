//
//  ChatListViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/7/2564 BE.
//

import UIKit
import ConnectyCube
import Firebase

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var user: Firebase.User!
    var customer: Customer?
    
    var dialogList:[ChatDialog] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "แชท"
        
        Chat.instance.connect(withUserID: 4554340, password: "123456") { error in
            print(error)
        }
//        CustomerManager().getCustomer { customer in
//            self.customer = customer
//            Chat.instance.connect(withUserID: 4554340, password: "123456") { error in
//               print(error)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ChatManager()
        Request.dialogs(with: Paginator.limit(100, skip: 0), extendedRequest: nil, successBlock: { (dialogs, usersIDs, paginator) in
            print(dialogs)
            self.dialogList = dialogs
            self.tableView.reloadData()
            print("xxxxxx")
            print(usersIDs)
            print("xxxxxx")
            
        }) { (error) in
            
        }
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Chat.instance.disconnect { (error) in
            
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dailog = self.dialogList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailogCell", for: indexPath) as! DailogCell
        cell.nameLabel?.text = dailog.name
        cell.messageLabel?.text = dailog.lastMessageText
        cell.timeLabel?.text = dailog.lastMessageDate?.timeAgoDisplay()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dialog = self.dialogList[indexPath.row]
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MessageingViewController") as! MessageingViewController
        viewController.chatdialog = dialog
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
