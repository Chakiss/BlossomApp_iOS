//
//  CustomerManager.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import Foundation
import Firebase
import PushKit
import ConnectyCube

class CustomerManager: NSObject, PKPushRegistryDelegate {
    
    static let sharedInstance = CustomerManager()
    private weak var storage = Storage.storage()
    private weak var user = Auth.auth().currentUser
    private weak var db = Firestore.firestore()
    
    private(set) var customer: Customer? = nil
    private var deviceToken: Data?

    private override init() { }
     
     func logout() {
         user = Auth.auth().currentUser
         customer = nil
     }
    
    func getCustomer(completion: @escaping ()->Swift.Void )  {
        if user == nil {
            // Try to get user before fetching
            user = Auth.auth().currentUser
        }
        
        guard user != nil else {
            completion()
            return
        }
        
        db?.collection("customers").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            
            let customer = (snapshot?.data().map({ documentData -> Customer in
                let id = snapshot?.documentID ?? ""
                let createdAt = documentData["createdAt"] as? String ?? ""
                let displayName = documentData["displayName"] as? String ?? ""
                let email = documentData["email"] as? String ?? ""
                let firstName = documentData["firstName"] as? String ?? ""
                let isEmailVerified: Bool = (documentData["isEmailVerified"] ?? false) as! Bool
                let isPhoneVerified: Bool = (documentData["isPhoneVerified"] ?? false) as! Bool
                let lastName = documentData["lastName"] as? String ?? ""
                let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                let platform = documentData["platform"] as? String ?? ""
                let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? String ?? ""
                let referenceShipnityID = documentData["referenceShipnityID"] as? String ?? ""
                let updatedAt = documentData["updatedAt"] as? String ?? ""
                let gender = documentData["gender"] as? String ?? ""
                let birthDateTimestamp = documentData["birthDate"] as? Timestamp
                var birthDay = ""
                var birthDayString = ""
                var birthDayDisplayString = ""
                if let birthDate = birthDateTimestamp?.dateValue() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    birthDayString = dateFormatter.string(from: birthDate)
                    birthDay = dateFormatter.string(from: birthDate)
                    dateFormatter.dateStyle = .medium
                    birthDayDisplayString = dateFormatter.string(from: birthDate)
                }
                
                let tmpAddress = documentData["address"] as? [String : Any] ?? [:]
                var address = Address()
                address.address = tmpAddress["address"] as? String ?? ""
                
                
                let genderString = gender
                
                let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                
                let skinType = documentData["skinType"] as? String ?? ""
                let acneType = documentData["acneType"] as? String ?? ""
                let acneCaredDescription = documentData["acneCaredDescription"] as? String ?? ""
                let allergicDrug = documentData["allergicDrug"] as? String ?? ""
                
                let documentSnapshot = snapshot?.reference
                
                return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt, gender: gender,genderString: genderString, birthDate: birthDay,birthDayDisplayString: birthDayDisplayString, birthDayString: birthDayString, address: address, displayPhoto: displayPhoto,skinType: skinType, acneType: acneType, acneCaredDescription: acneCaredDescription, allergicDrug: allergicDrug,documentReference: documentSnapshot!
                )
                
            }))
            
            guard customer != nil else {
                completion()
                return
            }
            
            self.customer = customer
            self.voipRegistration()
            completion()
        }
    }
    
    func saveDeviceToken(_ deviceToken: Data) {
        self.deviceToken = deviceToken
    }
    
    private func voipRegistration() {
        
        let cid = CustomerManager.sharedInstance.customer?.email ?? ""
        Request.logIn(withUserLogin: cid, password: CustomerManager.sharedInstance.customer?.id ?? "", successBlock: { [weak self] (user) in
            print(user)
            
            let mainQueue = DispatchQueue.main
            let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
            voipRegistry.delegate = self
            voipRegistry.desiredPushTypes = [PKPushType.voIP]
            self?.createSubscription()
            
        }) { (error) in
            print(error)
        }
        
     }
    
    private func createSubscription() {
        let subcription = Subscription()
        subcription.notificationChannel = .APNS
        subcription.deviceToken = deviceToken
        subcription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        Request.createSubscription(subcription, successBlock: { (subscriptions) in
            debugPrint("createSubscription APNS \(subscriptions)")
        }) { (error) in
            debugPrint("createSubscription APNS error \(error)")
        }

    }
        
    // Handle updated push credentials

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        print(pushCredentials.token)
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString

        let subscription: Subscription! = Subscription()
        subscription.notificationChannel = NotificationChannel.APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = pushCredentials.token

        Request.createSubscription(subscription, successBlock: { (subscriptions) in
            print(subscriptions)
        }) { (error) in
            print(error)
        }
    }
    
    // MARK: - PKPushRegistryDelegate protocol

       func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
           print("pushRegistry:didInvalidatePushTokenForType:")
       }
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("didReceiveIncomingPushWithPayload")
    }
}
