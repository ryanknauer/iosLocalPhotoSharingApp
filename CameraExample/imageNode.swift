//
//  imagesNode.swift
//  CameraExample
//
//  Created by Ryan Knauer on 9/15/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation
import UIKit

protocol ViewController2Delegate: class {
    func updateTopImage()
}

class imageNode{
    var imageURL: String?
    var id: Int!
    var rank: Int!
    var votes: Int!
    var upVotes: NSArray
    var downVotes: NSArray
    var imageData: NSData?
    var voteButtonPressed: votePressed = .none
    var status: downloadStatus = .loading
    var isCurrentImageNode: Bool = false
    var delegate: ViewController2Delegate?
    enum votePressed{
        case up
        case down
        case none
    }
    enum downloadStatus{
        case complete
        case loading
        case failed
    }
    
    init(imgURL: String, idNum: Int, rankNum: Int, votesNum: Int, upVoted: NSArray, downVoted: NSArray){
        imageURL = imgURL
        id = idNum
        rank = rankNum
        votes = votesNum
        upVotes = upVoted
        downVotes = downVoted
        updateVotePressed()
    }
    
    func updateVotePressed(){
        if upVotes.containsObject(User.userName){
            voteButtonPressed = .up
        }else if downVotes.containsObject(User.userName){
            voteButtonPressed = .down
        }
    }
    
    
    func downloadTopImage(){
        if let URL = self.imageURL, nsurl = NSURL(string:URL){
            print(URL)
            downloadImageFromURL(nsurl, completionHandler: { (success) -> Void in
                if success{
                    print("CHTEST should come second")
                    self.status = .complete
                    print("sucess!")
                    if self.isCurrentImageNode{
                        self.delegate?.updateTopImage()
                    }
                    
                }else{
                    self.status = .failed
                    print("failure")
                    //todo !!! handle no image found
                }
            })
        
        }
        print("CHTEST should come first")
    }
    
    func downloadImageFromURL(url: NSURL, completionHandler: (success:Bool) -> Void){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            var result: Bool
            
            if let data = NSData(contentsOfURL: url){
                self.imageData = data
                result = true
            } else {
                result = false
            }
            
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(success: result)
            }
            
        }

    }
    
    
}