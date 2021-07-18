//
//  MessageingViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 19/7/2564 BE.
//

import UIKit
import ConnectyCube
import CommonKeyboard

class MessageingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var chatdialog: ChatDialog?
    var chatMessageList: [ChatMessage] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    let keyboardObserver = CommonKeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = chatdialog?.name
        
        tableView.keyboardDismissMode = .interactive
        
        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            let bottom = (info.isShowing
                ? (-info.visibleHeight) + weakSelf.view.backwardSafeAreaInsets.bottom
                : 0
            )
            UIView.animate(info, animations: { [weak self] in
                self?.bottomConstraint.constant = bottom
                self?.view.layoutIfNeeded()
            })
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Request .messages(withDialogID: chatdialog?.id ?? "",
                          extendedRequest: ["date_sent[gt]":"1455098137"],
                          paginator: Paginator.limit(200, skip: 0),
                          successBlock: { (messages, paginator) in
                            self.chatMessageList = messages
                            self.tableView.reloadData()
            
        }) { (error) in

        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = self.chatMessageList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailogCell", for: indexPath) as! DailogCell
        cell.nameLabel?.text = chatMessage.text
        cell.messageLabel?.text = chatMessage.senderResource
        cell.timeLabel?.text = chatMessage.dateSent?.timeAgoDisplay()
        
        return cell
    }
    
    

    @IBAction func sendMessageButtonTapped() {
        let message = ChatMessage()
        message.text = "How are you today?"

        chatdialog?.send(message, completionBlock: { error in
            print(error)
        })
        
        //let privateDialog: ChatDialog = ChatDialog(dialogID: , type: <#T##ChatDialogType#>)
        //privateDialog.send(message) { (error) in

        //}
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

extension MessageingViewController: CommonKeyboardContainerProtocol {
    // return specific scrollViewContainer
    // UIScrollView or a class that inherited from (e.g., UITableView or UICollectionView)
    var scrollViewContainer: UIScrollView {
        return tableView
    }
}

extension UIView {
    var backwardSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        }
        return .zero
    }
}
