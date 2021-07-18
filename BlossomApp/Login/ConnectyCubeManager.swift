//
//  ConnectyCubeManager.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import Foundation
import ConnectyCube

class ConnectyCubeManager {
    
    func login() {
        Request.logIn(withUserLogin: "iphone@iphone.com", password: "123456", successBlock: { (user) in
            print(user)
        }) { (error) in
            print("xxxxxx")
        }
    }
    
    func logout(){
        Request.logOut(successBlock: {

        }) { (error) in

        }
    }
}


class ChatManager : NSObject {
    
    override init() {
        super.init()
        Chat.instance.addDelegate(self)
    }
}

//MARK: ChatDelegate

extension ChatManager : ChatDelegate {
    
    func chatDidConnect() {
    }
    
    func chatDidReconnect() {
    }
    
    func chatDidDisconnectWithError(_ error: Error) {
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
    }
}
