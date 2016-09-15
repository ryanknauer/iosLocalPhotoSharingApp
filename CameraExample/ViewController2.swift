   //  ViewController2.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/20/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import Alamofire





class ViewController2: UIViewController {
    
    @IBOutlet var votesLabel: UILabel!

    @IBOutlet var ImageView1: UIImageView!

    @IBOutlet var sortingSegmentedControl: UISegmentedControl!
    
    @IBOutlet var upVoteButton: UIButton!
    
    @IBOutlet var downVoteButton: UIButton!
    
    @IBOutlet var commentsButton: UIButton!
    
    @IBOutlet var nextPictureButton: UIButton!
    
    @IBOutlet var refreshButton: UIButton!
    

    
    enum sortingStyles: String{
        case top = "top"
        case new = "new"
    }
    
    var imageViewQueue: Queue<imageNode> = Queue<imageNode>()
    var currentImageViewNode: imageNode!
    var sortingMethod: sortingStyles = .top
    let upVoteColor = UIColor.orangeColor()
    let downVoteColor = UIColor.lightGrayColor()
    let baseColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1.0)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagesFromServer()
        self.ImageView1.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        hideAllButtons(false)
    }

    

    func bringUpTopImage(){
        currentImageViewNode = imageViewQueue.deQueue()
        if let URL = currentImageViewNode?.imageURL{
            print(URL)
            let url = NSURL(string:URL)
            let data = NSData(contentsOfURL:url!)
            if data != nil {
                ImageView1.image = UIImage(data:data!)
                let votes = currentImageViewNode?.votes
                votesLabel.text = String(votes!)
                setVoteColor()
            }
        }
        
    }

    
    
    func setupImagesFromServer() {
        
        let baseURL = baseHTTPURL + "quickstart/"
        let URL = baseURL + sortingMethod.rawValue
        
        Alamofire.request(.GET,  URL, headers: User.headers)
                 .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    self.deSerializeJson(response.data)
                    self.bringUpTopImage()
        }
    }
    
    
    
    func deSerializeJson(data: NSData?){
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let snippets = JSON as? [[String: AnyObject]] {
                for snippet in snippets{
                    if let imageURL = snippet["photo"] as? String{
                        let id: Int? = snippet["id"]?.integerValue
                        let rank: Int? = snippet["rank"]?.integerValue
                        let votes: Int? = snippet["votes"]?.integerValue
                        let upVoted = snippet["upVotes"] as! NSArray
                        let downVoted = snippet["downVotes"] as! NSArray
                        imageViewQueue.enQueue((imageNode(imgURL: imageURL, idNum: id!, rankNum: rank!, votesNum: votes!, upVoted: upVoted, downVoted: downVoted)))
                    }
                }
            }
        }
            
        catch{
            print("Json Error: \(error)")
        }
        
    }
    
    
    @IBAction func nextPhotoButton(sender: UIButton) {
        self.bringUpTopImage()
    }
    
    
    
    
    
// string "up/down/-up/-down/" is what is appended to url to change votes - indicates subtracting 1 if already up/down voted by user
    @IBAction func downVoteButtonPressed(sender: UIButton) {
        if let votes = currentImageViewNode?.votes{
            switch currentImageViewNode.voteButtonPressed{
            case .down:
                votesLabel.text = String(votes + 1)
                currentImageViewNode.votes = votes + 1
                currentImageViewNode.voteButtonPressed = .none
                updateVote("-down")
            case .up:
                votesLabel.text = String(votes - 2)
                currentImageViewNode.votes = votes - 2
                currentImageViewNode.voteButtonPressed = .down
                updateVote("down")
            case .none:
                votesLabel.text = String(votes - 1)
                currentImageViewNode.votes = votes - 1
                currentImageViewNode.voteButtonPressed = .down
                updateVote("down")
            }
            setVoteColor()
        }
    }
    
    
    @IBAction func upVoteButtonPressed(sender: UIButton) {
        if let votes = currentImageViewNode?.votes{
            switch currentImageViewNode.voteButtonPressed{
            case .up:
                votesLabel.text = String(votes - 1)
                currentImageViewNode.voteButtonPressed = .none
                currentImageViewNode.votes = votes - 1
                updateVote("-up")
            case .down:
                votesLabel.text = String(votes + 2)
                currentImageViewNode.voteButtonPressed = .up
                currentImageViewNode.votes = votes + 2
                updateVote("up")
            case .none:
                votesLabel.text = String(votes + 1)
                currentImageViewNode.voteButtonPressed = .up
                currentImageViewNode.votes = votes + 1
                updateVote("up")
            }
            setVoteColor()
        }
    }
    
    
    
    func updateVote(upOrDown: String){
        // "1" represents up "0" represents down
        if let id = currentImageViewNode?.id {
            let url = baseHTTPURL + "quickstart/" + String(id) + "/" + upOrDown + "/"
            print(url)
            Alamofire.request(.GET, url, headers: User.headers)
                .responseJSON { response in
                    debugPrint(response)
            }

        }
    }
    
    
    
    func setVoteColor(){
        switch currentImageViewNode.voteButtonPressed{
        case .up:
            votesLabel.textColor = upVoteColor
            upVoteButton.setTitleColor(upVoteColor, forState: UIControlState.Normal)
            downVoteButton.setTitleColor(baseColor, forState: UIControlState.Normal)
        case .down:
            votesLabel.textColor = downVoteColor
            upVoteButton.setTitleColor(baseColor, forState: UIControlState.Normal)
            downVoteButton.setTitleColor(downVoteColor, forState: UIControlState.Normal)
        case .none:
            votesLabel.textColor = baseColor
            upVoteButton.setTitleColor(baseColor, forState: UIControlState.Normal)
            downVoteButton.setTitleColor(baseColor, forState: UIControlState.Normal)
        }
        
    }
    
    
    @IBAction func filterValueChanged(sender: UISegmentedControl) {
        switch sortingSegmentedControl.selectedSegmentIndex{
        case 0:
            sortingMethod = .top
        case 1:
            sortingMethod = .new
        default:
            sortingMethod = .top
        }
        
        
    }
    

    @IBAction func commentsButtonPressed(sender: AnyObject) {
        hideAllButtons(true)
    }
    
    
    @IBAction func resetButtonPressed(sender: UIButton) {
        imageViewQueue = Queue<imageNode>()
        setupImagesFromServer()
    }
    
    
    func hideAllButtons(bool: Bool){
        upVoteButton.hidden = bool
        downVoteButton.hidden = bool
        commentsButton.hidden = bool
        nextPictureButton.hidden = bool
        refreshButton.hidden = bool
        votesLabel.hidden = bool
        sortingSegmentedControl.hidden = bool
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCommentsSegue"{
            if let destination = segue.destinationViewController as? commentsViewController{
                destination.snippetID = String(self.currentImageViewNode.id)
            }
        }
    }
    

}




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
        if upVotes.containsObject(User){
            voteButtonPressed = .up
        }else if downVotes.containsObject(User){
            voteButtonPressed = .down
        }
    }
}





