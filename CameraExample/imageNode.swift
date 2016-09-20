//
//  imagesNode.swift
//  CameraExample
//
//  Created by Ryan Knauer on 9/15/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation
import UIKit

class imageNode{
    var imageURL: String?
    var id: Int!
    var rank: Int!
    var votes: Int!
    var upVotes: NSArray
    var downVotes: NSArray
    var voteButtonPressed: votePressed = .none
    enum votePressed{
        case up
        case down
        case none
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
}