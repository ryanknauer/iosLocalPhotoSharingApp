//
//  SetupImagesFromServer.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/21/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

//import Foundation
//import Alamofire
//
//
//
//
//class imageNode{
//    var imageURL: String?
//    var id: Int!
//    var rank: Int!
//    var votes: Int!
//    
//    init(imgURL: String?, idNum: Int, rankNum: Int, votesNum: Int){
//        imageURL = imgURL
//        id = idNum
//        rank = rankNum
//        votes = votesNum
//    }
//}
//    
//
//
//func setupImagesFromServer() {
//    
//    Alamofire.request(.GET, "http://0.0.0.0:8000/quickstart/")
//        .responseJSON { response in
//            print(response.request)  // original URL request
//            print(response.response) // URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
//            deSerializeJson(response.data!)
//    }
//    
//}
//
//
//func deSerializeJson(data: NSData){
//    do {
//        let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//        
//        if let snippets = JSON as? [[String: AnyObject]] {
//            for snippet in snippets{
//                if let imageURL = snippet["photo"] as? String{
//                    let id = Int(snippet["id"] as! String)
//                    let rank = Int(snippet["rank"] as! String)
//                    let votes = Int(snippet["votes"] as! String)
//                    //imageViewQueue.enQueue((imageNode(imgURL: imageURL, idNum: id!, rankNum: rank!, votesNum: votes!)))
//                }
//            }
//        }
//    }
//        
//        catch{
//            print("Json Error: \(error)")
//            }
//    
//}