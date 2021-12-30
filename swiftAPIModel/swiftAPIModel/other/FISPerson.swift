//
//  FISPerson.swift
//  swiftAPIModel
//
//  Created by Mohammad Dawi on 12/26/21.
//  Copyright © 2021 Mohammad Dawi. All rights reserved.
//

import Foundation
class FISPerson: NSObject {
    private var _name: String?
    var name:String? {
        get {
            return _name
        }
        
        set {
            _name = newValue
        }
    }
    init(name:String="mhd") {
        super.init()
        self.name = name
    }
    
    static func create(fromDictionary personDictionary: [AnyHashable : Any]?) -> FISPerson? {
        let newPerson = FISPerson(
            name: personDictionary?["name"] as! String)
        return newPerson
    }
    
}
