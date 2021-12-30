//
//  FISClass.swift
//  swiftAPIModel
//
//  Created by Mohammad Dawi on 12/26/21.
//  Copyright © 2021 Mohammad Dawi. All rights reserved.
//

import Foundation
class FISClass {
    var name: String?
    var roomNumber: Int?
    var instructor: FISPerson?
    var students: [AnyHashable]?
        init(
            name: String="",
            roomNumber: Int=0,
            instruct: FISPerson?=nil,
            students: [AnyHashable]=[])
        {
            self.name=name
            self.roomNumber=roomNumber
            self.instructor = instruct
            self.students=students
    }

    convenience init(
        name: String,
        roomNumber: Int
    ) {
        let p = FISPerson()
        self.init(
            name: name,
            roomNumber: roomNumber,
            instruct: p,
            students: [])
    }
    
    static func create(fromDictionary classDictionary: [String : Any]?) -> FISClass? {
        
        let instructor = FISPerson.create(fromDictionary: classDictionary?["instructor"] as! [String: Any])
        var mStudents: [AnyHashable] = []
        for studentDictionary in classDictionary?["students"] as! [AnyObject]{
            let student = FISPerson.create(
                fromDictionary: studentDictionary as! [String : Any])
            if let student = student {
                mStudents.append(student)
            }
        }
        let students = Array(mStudents)
        let newClass = FISClass(
            name: classDictionary?["name"] as! String,
            roomNumber: classDictionary?["roomNumber"] as! Int,
            instruct: instructor,
            students: students)
        return newClass
    }
}
