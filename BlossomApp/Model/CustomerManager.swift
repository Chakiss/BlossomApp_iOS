//
//  CustomerManager.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import Foundation
import Firebase

class CustomerManager {
    
    static let sharedInstance = CustomerManager()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    var customer: Customer? = nil//{
        //get { counter += 1; return data; }
        //set { _data = customer; }
    //}

    init() { }
    
    
    func getCustomer(completion: @escaping ()->Swift.Void )  {
        guard user != nil else {
            completion()
            return
        }
        
        db.collection("customers").document(user?.uid ?? "").addSnapshotListener { snapshot, error in
            
            self.customer = (snapshot?.data().map({ documentData -> Customer in
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
                
            }))!
         //   successCallback(customer!)
            completion()
        }
    }
}
