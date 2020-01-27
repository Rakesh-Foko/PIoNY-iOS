//
//  ConditionsModel.swift
//  PloNY
//
//  Created by Rakesh Tripathi on 2020-01-23.
//  Copyright © 2020 Rakesh Tripathi. All rights reserved.
//

import UIKit

class ConditionsModel: NSObject {
    
    var id: Int
    var name: String
    var desc: String
    
    internal init(id: Int, name: String, desc: String) {
        self.id = id
        self.name = name
        self.desc = desc
    }
    
    init (json:[String:Any]) {
        self.id = json["id"] as? Int ?? 0
        self.name = json["name"] as? String ?? ""
        self.desc = json["description"] as? String ?? ""
    }
}
