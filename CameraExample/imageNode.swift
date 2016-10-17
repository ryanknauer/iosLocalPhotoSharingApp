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
    func updateTopNode()
    
}


enum mediaType{
    case image
    case video
}

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


class mediaNode{
    var mediaURL: String?
    var id: Int!
    var rank: Int!
    var votes: Int!
    var upVotes: NSArray
    var downVotes: NSArray
    var medType: mediaType!
    var voteButtonPressed: votePressed = .none
    var status: downloadStatus = .loading
    var isCurrentMediaNode: Bool = false
    var delegate: ViewController2Delegate?
    var mediaData: NSData?
    var loadPathNumber: String!
    var pathToDownloadedMedia: videoClass!

    
    init(medURL: String, idNum: Int, rankNum: Int, votesNum: Int, upVoted: NSArray, downVoted: NSArray, mType: mediaType, loadPN: String){
        mediaURL = medURL
        id = idNum
        rank = rankNum
        votes = votesNum
        upVotes = upVoted
        downVotes = downVoted
        medType = mType
        loadPathNumber = loadPN
        pathToDownloadedMedia = videoClass(string: loadPathNumber)
        updateVotePressed()
    }
    
    
    func updateVotePressed(){
        if upVotes.containsObject(User.userName){
            voteButtonPressed = .up
        }else if downVotes.containsObject(User.userName){
            voteButtonPressed = .down
        }
    }
    
    func dataExists(data: NSData) {
        self.mediaData = data
        pathToDownloadedMedia.clearCurrentVideoPath()
        let success = data.writeToURL(pathToDownloadedMedia.currentVideoURL, atomically: true)
        if success{
            print("saved!")
        }else{
            // handle error
            print("not saved!!!")
        }
    }
    
    func dataDNE() {
        
    }
    
    
    func downloadTopImage(){
        if let URL = mediaURL, nsurl = NSURL(string:URL){
            print(URL)
            downloadImageFromURL(nsurl, completionHandler: { (success) -> Void in
                if success{
                    print("CHTEST should come second")
                    self.status = .complete
                    print("sucess!")
                    if self.isCurrentMediaNode{
                        self.delegate?.updateTopNode()
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
    
    
    func downloadImageFromURL(url: NSURL, completionHandler: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            var result: Bool
            
            if let data = NSData(contentsOfURL: url){
                self.dataExists(data)
                result = true
            } else {
                self.dataDNE()
                result = false
            }
            
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(success: result)
            }
            
        }
        
    }

}






//
//protocol mediaDownload{
//    var mediaURL: String?{get set}
//    var status: downloadStatus{get set}
//    var isCurrentMediaNode: Bool{get set}
//    var delegate: ViewController2Delegate?{get set}
//    
//
//    func dataExists(data: NSData)
//    func dataDNE()
//    }
//
//extension mediaDownload{
//    
//    mutating func downloadTopImage(){
//        if let URL = mediaURL, nsurl = NSURL(string:URL){
//            print(URL)
//            downloadImageFromURL(nsurl, completionHandler: { (success) -> Void in
//                if success{
//                    print("CHTEST should come second")
//                    self.status = .complete
//                    print("sucess!")
//                    if self.isCurrentMediaNode{
//                        self.delegate?.updateTopImage()
//                    }
//                    
//                }else{
//                    self.status = .failed
//                    print("failure")
//                    //todo !!! handle no image found
//                }
//            })
//            
//        }
//        print("CHTEST should come first")
//    }
//    
//    
//    func downloadImageFromURL(url: NSURL, completionHandler: (success: Bool) -> Void) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
//            var result: Bool
//            
//            if let data = NSData(contentsOfURL: url){
//                self.dataExists(data)
//                result = true
//            } else {
//                self.dataDNE()
//                result = false
//            }
//            
//            dispatch_async(dispatch_get_main_queue()){
//                completionHandler(success: result)
//            }
//            
//        }
//        
//    }
//
//}
//



//class videoNode: mediaNode, mediaDownload{
//    var videoPath: videoClass = videoClass(string: "2")
//    
//    override func dataExists(data: NSData) {
//        videoPath.clearCurrentVideoPath()
//        
//    }
//    
//    override func dataDNE() {
//        
//    }
//    
//}
//
//
//class imageNode: mediaNode, mediaDownload{
//
//    var imageData: NSData?
//    
//    func dataExists(data: NSData) {
//        self.imageData = data
//    }
//    
//    func dataDNE() {
//        
//    }
//    func downloadTopImage(){
//        if let URL = self.mediaURL, nsurl = NSURL(string:URL){
//            print(URL)
//            downloadImageFromURL(nsurl, completionHandler: { (success) -> Void in
//                if success{
//                    print("CHTEST should come second")
//                    self.status = .complete
//                    print("sucess!")
//                    if self.isCurrentMediaNode{
//                        self.delegate?.updateTopImage()
//                    }
//                    
//                }else{
//                    self.status = .failed
//                    print("failure")
//                    //todo !!! handle no image found
//                }
//            })
//        
//        }
//        print("CHTEST should come first")
//    }
//    func downloadImageFromURL(url: NSURL, completionHandler: (success:Bool) -> Void){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
//            var result: Bool
//            
//            if let data = NSData(contentsOfURL: url){
//                self.imageData = data
//                result = true
//            } else {
//                result = false
//            }
//            
//            dispatch_async(dispatch_get_main_queue()){
//                completionHandler(success: result)
//            }
//            
//        }
//
//    }
