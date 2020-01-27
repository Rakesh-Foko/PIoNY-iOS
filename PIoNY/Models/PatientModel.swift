//
//  PatientModel.swift
//  PloNY
//
//  Created by Rakesh Tripathi on 2020-01-23.
//  Copyright © 2020 Rakesh Tripathi. All rights reserved.
//

import UIKit

class PatientModel: NSObject {
    
    
    var id : Int
    var mobilePhone: String
    var firstName: String
    var lastName: String
    var streerAdress: String
    var city: String
    var state: String
    var postalCode: Int
    var conditions: ConditionsModel
    var status: Bool
    
    
    internal init(id: Int, mobilePhone: String, firstName: String, lastName: String, streerAdress: String, city: String, state: String, postalCode: Int, conditions: ConditionsModel, status: Bool) {
        self.id = id
        self.mobilePhone = mobilePhone
        self.firstName = firstName
        self.lastName = lastName
        self.streerAdress = streerAdress
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.conditions = conditions
        self.status = status
    }
    
    
    init (json:[String:Any]) {
        self.id = json["id"] as? Int ?? 0
        self.mobilePhone = json["mobilePhone"] as? String ?? ""
        self.firstName = json["firstName"] as? String ?? ""
        self.lastName = json["lastName"] as? String ?? ""
        self.streerAdress = json["streerAdress"] as? String ?? ""
        self.city = json["city"] as? String ?? ""
        self.state = json["state"] as? String ?? ""
        let postalCodeStr = json["postalCode"] as? String ?? "0"
        self.postalCode = Int(postalCodeStr) ?? 0
        self.status = json["status"] as? Bool ?? false
        let conditionsJson = json["conditions"] as? [String:Any] ?? ["":""]
        self.conditions = ConditionsModel.init(json: conditionsJson)
    }
    

}
