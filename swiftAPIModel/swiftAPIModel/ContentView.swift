//
//  ContentView.swift
//  swiftAPIModel
//
//  Created by Mohammad Dawi on 12/26/21.
//  Copyright © 2021 Mohammad Dawi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var p = FISPerson(name: "mhd")
    
    func myPrint(msg:String){
        print(msg)
    }
    
    //myPrint(p.name)
    
    
    //Debug this please!!!
    /*
    let zachDrossman = FISPerson(name: "Zach Drossman")
    let markMurray = FISPerson(name: "Mark Murray")
    let anishKumar = FISPerson(name: "Anish Kumar")
    let ios004 = FISClass(
        name: "ios004",
        roomNumber: Int(NSNumber(value: 4)),
        instruct: zachDrossman,
        students: [markMurray, anishKumar])
    */
    

    let ios004 = FISClass(
        name: "ios004",
        roomNumber: Int(NSNumber(value: 4)),
        instruct: FISPerson(name: "Zach Drossman"),
        students: [FISPerson(name: "Mark Murray"), FISPerson(name: "Anish Kumar")])
    
    
    //var emptyDictionary = [String: String]()
    
    let sk = FISPerson.create(fromDictionary: ["name": "starkellen"])
    
    let ece330 = FISClass.create(fromDictionary: ["instructor":["name":"Dawi"],"students":[["name": "Mark Murray"], ["name": "Anish Kumar"]], "name":"ece330","roomNumber":106])
    
    var body: some View {
        //var x = print("Update body") // 1
        //let y = print("Update body") // 2
        let _ = print(ios004.instructor?.name) // 3
        let _ = print(sk?.name)
        return Text(String((ece330?.instructor!.name!)!))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
