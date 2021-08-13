//
//  PushMessage.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/8/2564 BE.
//

import Foundation
import Firebase
import FirebaseFunctions

class PushMessage {
    
    func pushTo(targetID : String, type: String, subType: String, title: String, message: String, payload: [String:String] ){
        
        let functions = Functions.functions()
        
        let functionPayload = ["targetID": targetID,
                               "type": type,
                               "subType": subType,
                               "title": title,
                               "message": message,
                               "payload": payload] as [String : Any]
        
        functions.httpsCallable("app-users-signUpWithEmailAndPassword").call(functionPayload) { result, error in
            
        }
        
    }
}
