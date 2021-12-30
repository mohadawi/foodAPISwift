//
//  HTTPClient.swift
//
//  Mohammad Dawi
// note this class is semi-generic, just need to maipulate the type of the json response

import Foundation
import UIKit

class HTTPClient {
    //holds the rpeos list (is it useful to consider moving it up level in listAPI class?!)
    var repos = [Pizza]()
    var totalCount:Int = 0

    init() {
        
    }
    //get the list of repos "articles" (request returns 10 results per page)
    func getRequestAPICall(_ apiUurl: String?,completion: @escaping (Error?) -> Void)
     {
        repos.removeAll()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest()
        request.httpMethod = "GET"
        request.url = URL(string: apiUurl!)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if error != nil {
                completion (error)
                return
            }
            var object: Any? = nil
            if let data = data {
                object = try? JSONSerialization.jsonObject(with: data, options: [])
            }
            if let object1 = object as? Array<Any>{
                //if let characters1 = object1["response"] as? [String:Any]{
                    let (arr,count)=Pizza.create(fromDictionary: object1)
                    self.repos.append(contentsOf: arr)
                    self.totalCount=count
                }
            //}
            completion (error)
        })
        task.resume()
    }
    
    func getRepos(url:String?,completion: @escaping (Error?) -> Void) {
        getRequestAPICall(url,completion:{(error) in
            completion(error)
            if(error == nil){
                // do something if needed
            }
        })
    }
    
    func downloadImage(_ url: String) -> UIImage? {
        let aUrl = URL(string: url)
        guard let data = try? Data(contentsOf: aUrl!),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
    }
    
}
