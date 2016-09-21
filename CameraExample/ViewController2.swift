   //  ViewController2.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/20/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import Alamofire





class ViewController2: UIViewController, ViewController2Delegate {
    
    @IBOutlet var votesLabel: UILabel!

    @IBOutlet var ImageViewButton: UIButton!
    
    @IBOutlet var sortingSegmentedControl: UISegmentedControl!
    
    @IBOutlet var commentsButton: UIButton!
    
    @IBOutlet var refreshButton: UIButton!
    
    var buttonImageView = UIButton(type: UIButtonType.Custom) as UIButton
    
    enum sortingStyles: String{
        case top = "top"
        case new = "new"
    }
    
    var imageViewQueue: Queue<imageNode> = Queue<imageNode>()
    var nextImageViewNode: imageNode?
    var currentImageViewNode: imageNode!
    var sortingMethod: sortingStyles = .top
    let upVoteColor = UIColor.orangeColor()
    let downVoteColor = UIColor.lightGrayColor()
    let baseColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1.0)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height)
        buttonImageView.addTarget(self, action: "nextPhotoButton:", forControlEvents: UIControlEvents.TouchUpInside)
        //buttonImageView.view.contentMode = UIViewContentMode.ScaleAspectFill
        buttonImageView.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(buttonImageView)
        self.view.sendSubviewToBack(buttonImageView)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: "upVoteButtonPressed:")
        let downSwipe = UISwipeGestureRecognizer(target: self, action: "downVoteButtonPressed:")
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        
        setupImagesFromServer()
    }
        
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        hideAllButtons(false)
    }

    

    func bringUpTopImage(){
        if nextImageViewNode != nil{ // TODO Design What happens with Nil ImageView
            currentImageViewNode = nextImageViewNode!
            currentImageViewNode.delegate = self
            currentImageViewNode.isCurrentImageNode = true
            nextImageViewNode = imageViewQueue.deQueue()
            nextImageViewNode?.downloadTopImage()
            
            
            switch currentImageViewNode.status{
            case .complete:
                updateTopImage()
            case .loading:
                // todo !!! Loading default
                print("loading image")
            case .failed:
                // todo !!! failed defualt
                print("failed to load image")
            }
        }
    
    }
    
    
    func updateTopImage(){
        print("updateTopCalled")
        if let data = currentImageViewNode.imageData{
            buttonImageView.setImage(UIImage(data:data), forState: UIControlState.Normal)
            buttonImageView.setImage(UIImage(data:data), forState: UIControlState.Highlighted)
            let votes = currentImageViewNode?.votes
            votesLabel.text = String(votes!)
            setVoteColor()
        }
    }
    
    
    
    
    
    
//    func bringUpTopImage(){
//        currentImageViewNode = imageViewQueue.deQueue()
//        currentImageViewNode.downloadTopImage()
//        
//        if let URL = currentImageViewNode?.imageURL{
//            print(URL)
//            let url = NSURL(string:URL)
//            let data = NSData(contentsOfURL:url!)
//            if data != nil {
//                buttonImageView.setImage(UIImage(data:data!), forState: UIControlState.Normal)
//                buttonImageView.setImage(UIImage(data:data!), forState: UIControlState.Highlighted)
//                let votes = currentImageViewNode?.votes
//                votesLabel.text = String(votes!)
//                setVoteColor()
//            }
//        }
//    }
//    
    
    
    
    
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
        
        nextImageViewNode = imageViewQueue.deQueue()
        nextImageViewNode?.downloadTopImage()
        self.bringUpTopImage()
        
    }
    
    
    @IBAction func nextPhotoButton(sender: UIButton) {
        self.bringUpTopImage()
    }
    
    
    
    
    
// string "up/down/-up/-down/" is what is appended to url to change votes - indicates subtracting 1 if already up/down voted by user
    @IBAction func downVoteButtonPressed(sender: AnyObject) {
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
    
    
    
    
    @IBAction func upVoteButtonPressed(sender: AnyObject) {
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
        case .down:
            votesLabel.textColor = downVoteColor
        case .none:
            votesLabel.textColor = baseColor
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
        currentImageViewNode = nil
        nextImageViewNode = nil
        setupImagesFromServer()
    }
    
    
    func hideAllButtons(bool: Bool){
        commentsButton.hidden = bool
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










