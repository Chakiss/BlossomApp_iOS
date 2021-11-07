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
import Kingfisher
import GSImageViewerController

import Firebase

class MessageingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDelegate {

    var customer: Customer?
    var channelMessage: Channel?
    
    var chatdialog: ChatDialog?
    // case normal
    var chatMessageList: [ChatMessage] = []
    // case chat with admin
    var adminMessage: [Message] = []
    
    lazy var functions = Functions.functions()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var user = Auth.auth().currentUser
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    let keyboardObserver = CommonKeyboardObserver()
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.title = chatdialog?.name
        
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
        
        
        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardNotification(notification:)),
               name: UIResponder.keyboardWillChangeFrameNotification,
               object: nil)
        
        //Chat.instance.addDelegate(self)
        
       
        // Do any additional setup after loading the view.
    }
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
    
    @objc func keyboardNotification(notification: NSNotification) {
       guard let userInfo = notification.userInfo else { return }

       let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
       let endFrameY = endFrame?.origin.y ?? 0
       let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
       let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
       let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
       let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

       if endFrameY >= UIScreen.main.bounds.size.height {
         self.keyboardHeightLayoutConstraint?.constant = 0.0
       } else {
         self.keyboardHeightLayoutConstraint?.constant = ( endFrame?.size.height ?? 0.0) - 25
       }

       UIView.animate(
         withDuration: duration,
         delay: TimeInterval(0),
         options: animationCurve,
         animations: { self.view.layoutIfNeeded() },
         completion: nil)
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
        super.viewWillAppear(animated)
        if self.channelMessage != nil {
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
                        let images = data["images"]  as? [String] ?? []
                        
                        
                        message.isRead = isRead
                        message.message = messageText
                        
                        message.sendFrom = sendFrom
                        message.sendTo = sendTo
                        
                        message.createdAt = createdAt
                        message.updateAt = updatedAt
                        message.images = images
                        return message
                    })
                    self.channelMessage?.message = messages
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    
                }
            
            
            let payload: [String: Any] = [
                "channelID": self.channelMessage?.id
            ]
            
            
            self.functions.httpsCallable("app-messages-markChannelMessagesRead").call(payload) { result, error in
                
                if error == nil {
                    
                } else {
                    
                }
            }
        } else {
            
            self.db.collection("channels")
                .document(user?.uid ?? "")
                .collection("messages")
                .order(by: "createdAt")
                .addSnapshotListener { messageData, error in
                    let messages = (messageData?.documents.map {messageSnapshot -> Message in
                        
                        
                        let data = messageSnapshot.data()
                        var message = Message(id: messageSnapshot.documentID)
                        
                        let isRead = data["isRead"]  as? Bool ?? nil
                        let messageText = data["message"] as? String ?? ""
                        let images = data["images"]  as? [String] ?? []
                        let from = data["from"]  as? String ?? ""
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
                        message.images = images
                        
                        message.from = from
                        return message
                    })
                    self.adminMessage = messages ?? []
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    
                }
            
            
            let payload: [String: Any] = [
                "channelID": user?.uid
            ]
            
            
            self.functions.httpsCallable("app-messages-markChannelMessagesRead").call(payload) { result, error in
                
                if error == nil {
                    
                } else {
                    
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channelMessage != nil {
            return self.channelMessage?.message?.count ?? 0
        } else {
            return self.adminMessage.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var chatMessage: Message!
        
        if self.channelMessage != nil {
            chatMessage = self.channelMessage?.message?[indexPath.row]
        } else {
            chatMessage = self.adminMessage[indexPath.row]
        }
        
        
        
        if chatMessage?.sendFrom?.documentID == user?.uid  ||  chatMessage.from == "user" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            cell.messageLabel.text = chatMessage?.message
            cell.timeLabel.text = chatMessage?.createdAt?.dateValue().timeAgoDisplay()
            if chatMessage?.images?.count ?? 0 > 0 {
                cell.messageLabel.text = ""
                cell.chatImageView.image = UIImage(named: "300")
                cell.chatImageView.image = UIImage(named: "placeholder")
                let storageRef = storage.reference().child(chatMessage?.images?[0] ?? "");
                storageRef.downloadURL { (URL, error) -> Void in
                  if (error != nil) {
                    // Handle any errors
                  } else {
                      cell.chatImageView.kf.setImage(with: URL)
                  }
                }
                
                cell.parent = self
                
            } else {
                cell.chatImageView.image = nil
            }
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
            cell.messageLabel.text = chatMessage?.message
            cell.timeLabel.text = chatMessage?.createdAt?.dateValue().timeAgoDisplay()
            if chatMessage?.images?.count ?? 0 > 0 {
                cell.messageLabel.text = ""
                cell.chatImageView.image = UIImage(named: "300")
                cell.chatImageView.image = UIImage(named: "placeholder")
                let storageRef = storage.reference().child(chatMessage?.images?[0] ?? "");
                storageRef.downloadURL { (URL, error) -> Void in
                  if (error != nil) {
                    // Handle any errors
                  } else {
                      cell.chatImageView.kf.setImage(with: URL)
                  }
                }
                cell.parent = self
                
            } else {
                cell.chatImageView.image = nil
            }
            return cell

            
        }
       
    }
    
    
   


    @IBAction func sendImageButtonTapped() {
        ImagePickerManager().pickImage(self){ image in
            
            if let imageData = image.jpeg(.low) {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                let encodeString:String = "data:image/jpeg;base64, \(strBase64)"
                
                if self.channelMessage != nil {
                    let payload = [
                        "channelID": self.channelMessage?.id ?? "",
                        "message": "",
                        "images": [encodeString]
                        
                    ] as [String : Any]
                    
                    ProgressHUD.show()
                    self.functions.httpsCallable("app-messages-pushChannelMessage").call(payload) { result, error in
                        
                        ProgressHUD.dismiss()
                        if error == nil {
                            
                        } else {
                            //let code = FunctionsErrorCode(rawValue: error.code)
                            let message = error?.localizedDescription
                            
                            self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: message ?? "", completion: {
                                
                            })
                        }
                    }
                    
                } else {
                    let payload = [
                        "message": "",
                        "images": [encodeString]
                        
                    ] as [String : Any]
                    
                    ProgressHUD.show()
                    self.functions.httpsCallable("app-messages-submitAdminMessage").call(payload) { result, error in
                        
                        ProgressHUD.dismiss()
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
    }
    
    @IBAction func sendMessageButtonTapped() {
        let message = self.textField.text
        self.textField.text = ""
        if self.channelMessage != nil {
            
            if message?.count ?? 0 > 0 {
                let payload = [
                    "channelID": self.channelMessage?.id ?? "",
                    "message": message ?? "",
                    "images": ""
                    
                ] as [String : Any]
                
                self.functions.httpsCallable("app-messages-pushChannelMessage").call(payload) { result, error in
                    
                    
                    if error == nil {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    } else {
                        
                        let errorMessage = error?.localizedDescription
                        self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: errorMessage ?? "", completion: {
                            
                        })
                    }
                }
            }
        } else {
            if message?.count ?? 0 > 0 {
                let payload = [
                    "message": message ?? "",
                    "images": ""
                    
                ] as [String : Any]
                
                self.functions.httpsCallable("app-messages-submitAdminMessage").call(payload) { result, error in
                    
                    
                    if error == nil {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    } else {
                        
                        let message = error?.localizedDescription
                        self.showAlertDialogue(title: "เกิดข้อผิดพลาก", message: message ?? "", completion: {
                            
                        })
                    }
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
            if self.channelMessage != nil {
                if self.channelMessage?.message?.count ?? 0 > 0 {
                    let indexPath = IndexPath(row: (self.channelMessage?.message?.count ?? 0) - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            } else {
                if self.adminMessage.count > 0 {
                    let indexPath = IndexPath(row: (self.adminMessage.count ) - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
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
