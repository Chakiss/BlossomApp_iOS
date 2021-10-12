//
//  MessageingViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 19/7/2564 BE.
//

import UIKit
import ConnectyCube
import CommonKeyboard
import SwiftDate
import SwiftyUserDefaults

import Firebase

class MessageingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDelegate {

    var customer: Customer?
    var channelMessage: Channel?
    
    var chatdialog: ChatDialog?
    var chatMessageList: [ChatMessage] = []
    
    lazy var functions = Functions.functions()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var user = Auth.auth().currentUser
    
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
        
        
       
        //Chat.instance.addDelegate(self)
        
       
        // Do any additional setup after loading the view.
    }
    
    func requestMessages() {
//        Request.messages(withDialogID: chatdialog?.id ?? "",
//                         extendedRequest: ["date_sent[gt]":"1455098137"],
//                         paginator: Paginator.limit(2000, skip: 0),
//                         successBlock: { (messages, paginator) in
//                            self.chatMessageList = messages
//                            self.chatMessageList.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedAscending })
//                            self.tableView.reloadData()
//                            self.scrollToBottom()
//                         }) { (error) in
//
//        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.db.collection("channels")
            .document(self.channelMessage?.id ?? "")
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { messageData, error in
                let messages = (messageData?.documents.map {messageSnapshot -> Message in
                    
                    
                    let data = messageSnapshot.data()
                    var message = Message(id: messageSnapshot.documentID)
                    
                    let isRead = data["isRead"]  as? Bool ?? nil
                    let messageText = data["message"] as? String ?? ""
                    let sendFrom = data["sendFrom"]  as? DocumentReference ?? nil
                    let sendTo = data["sendTo"]  as? DocumentReference ?? nil
                    let createdAt = data["createdAt"]  as? Timestamp ?? nil
                    let updatedAt = data["updatedAt"]  as? Timestamp ?? nil
                    
                    
                    message.isRead = isRead
                    message.message = messageText
                    
                    message.sendFrom = sendFrom
                    message.sendTo = sendTo
                    
                    message.createdAt = createdAt
                    message.updateAt = updatedAt
                    return message
                })
                self.channelMessage?.message = messages
                self.tableView.reloadData()
                self.scrollToBottom()

            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelMessage?.message?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let chatMessage = self.channelMessage?.message?[indexPath.row]
        
        //if chatMessage?.sendFrom == user
        if Defaults[\.role] == "customer"{
            
            //let customerConnectyCubeID = UInt((customer?.referenceConnectyCubeID)!)!
//            if  chatMessage.senderID == customerConnectyCubeID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            cell.messageLabel.text = chatMessage?.message
            cell.timeLabel.text = chatMessage?.createdAt?.dateValue().timeAgoDisplay()
                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
//                cell.messageLabel.text = chatMessage.text
//                cell.timeLabel.text = chatMessage.dateSent?.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.current)
//                return cell
//            }
        } else {
            
            //if  chatMessage.senderID == chatdialog?.userID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            cell.messageLabel.text = chatMessage?.message
            cell.timeLabel.text = chatMessage?.createdAt?.dateValue().timeAgoDisplay()
                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
//                cell.messageLabel.text = "chatMessage.text"
//                cell.timeLabel.text = "1234"
//                return cell
//            }
            
        }
       
    }
    

    @IBAction func sendImageButtonTapped() {
        ImagePickerManager().pickImage(self){ image in
            
            if let imageData = image.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                
                
                let payload = [
                    "channelID": self.channelMessage?.id ?? "",
                    "message": ".",
                    "images": encodeString
                    
                ] as [String : Any]
                
                self.functions.httpsCallable("app-messages-pushChannelMessage").call(payload) { result, error in

                
                    if error == nil {
                    
                    } else {
                        //let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error?.localizedDescription
                        
                        self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: message ?? "", completion: {
                            
                        })
                    }
                }
            }
           
        }
    }

    @IBAction func sendMessageButtonTapped() {
        if self.textField.text?.count ?? 0 > 0 {
            let payload = [
                "channelID": self.channelMessage?.id ?? "",
                "message": self.textField.text ?? "",
                "images": ""
                
            ] as [String : Any]
            
            self.functions.httpsCallable("app-messages-pushChannelMessage").call(payload) { result, error in
                
                
                if error == nil {
                    self.textField.text = ""
                    self.tableView.reloadData()
                    self.scrollToBottom()
                } else {
                    
                    let message = error?.localizedDescription
                    self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: message ?? "", completion: {
                        
                    })
                }
            }
        }
        /*
        if self.textField.text?.count ?? 0 > 0 {
            let message = ChatMessage()
            message.text = self.textField.text
            
            chatdialog?.send(message, completionBlock: { error in
                if error == nil {
                    self.textField.text = ""
                    self.chatMessageList.append(message)
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    
                    let recipientID = NSNumber(value:self.chatdialog!.recipientID)
                    
                    let event = Event()
                    event.notificationType = .push
                    event.usersIDs = [recipientID]
                    event.type = .oneShot
                    
                    let pushmessage = message.text! as String
                    var pushParameters = [String : String]()
                    pushParameters["message"] = pushmessage
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: pushParameters,
                                                                  options: .prettyPrinted) {
                        let jsonString = String(bytes: jsonData,
                                                encoding: String.Encoding.utf8)
                        
                        event.message = jsonString
                        
                        Request.createEvent(event, successBlock: {(events) in
                            print("xxxx")
                        }, errorBlock: {(error) in
                            print(error)
                        })
                    }
                    if Defaults[\.role] == "customer" {
                        
                        if recipientID == 4663567 {
                            let recipientIDNSNumber = recipientID as NSNumber
                            let recipientIDString = recipientIDNSNumber.stringValue
                            self.db.collection("customers")
                                .whereField("referenceConnectyCubeID", isEqualTo: recipientIDString)
                                .getDocuments { querySnapshot, error in
                                    guard error == nil else {
                                        return
                                    }
                                    if querySnapshot?.count ?? 0 > 0 {
                                        let document =  querySnapshot?.documents[0]
                                        PushMessage().pushTo(targetID: document?.documentID ?? "", type: "chat", subType: "toCustomer", title: "ข้อความ", message: pushmessage, payload: ["":""])
                                    }
                                    
                                }
                        } else {
                            self.db.collection("doctors")
                                .whereField("referenceConnectyCubeID", isEqualTo: recipientID)
                                .getDocuments { querySnapshot, error in
                                    guard error == nil else {
                                        return
                                    }
                                    if querySnapshot?.count ?? 0 > 0 {
                                        let document =  querySnapshot?.documents[0]
                                        PushMessage().pushTo(targetID: document?.documentID ?? "", type: "chat", subType: "toDoctor", title: "ข้อความ", message: pushmessage, payload: ["":""])
                                    }
                                    
                                }
                        }
                        
                    } else {
                        let recipientIDNSNumber = recipientID as NSNumber
                        let recipientIDString = recipientIDNSNumber.stringValue
                        self.db.collection("customers")
                            .whereField("referenceConnectyCubeID", isEqualTo: recipientIDString)
                            .getDocuments { querySnapshot, error in
                                guard error == nil else {
                                    return
                                }
                                if querySnapshot?.count ?? 0 > 0 {
                                    let document =  querySnapshot?.documents[0]
                                    PushMessage().pushTo(targetID: document?.documentID ?? "", type: "chat", subType: "toCustomer", title: "ข้อความ", message: pushmessage, payload: ["":""])
                                }
                                
                            }
                        
                        
                        
                    }
                    
                }
                
            })
        }
        
        */
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if self.channelMessage?.message?.count ?? 0 > 0 {
                let indexPath = IndexPath(row: (self.channelMessage?.message?.count ?? 0) - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        }
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
