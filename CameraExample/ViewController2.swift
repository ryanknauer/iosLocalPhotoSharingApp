
//  ViewController2.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/20/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AssetsLibrary




class ViewController2: UIViewController, ViewController2Delegate {
    
    @IBOutlet var votesLabel: UILabel!

    @IBOutlet var ImageViewButton: UIButton!
    
    @IBOutlet var sortingSegmentedControl: UISegmentedControl!
    
    @IBOutlet var commentsButton: UIButton!
    
    @IBOutlet var refreshButton: UIButton!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer!
    
    var buttonImageView = UIButton(type: UIButtonType.Custom) as UIButton
    
    enum sortingStyles: String{
        case top = "top"
        case new = "new"
    }
    
    var imageViewQueue: Queue<mediaNode> = Queue<mediaNode>()
    var nextImageViewNode: mediaNode?
    var currentImageViewNode: mediaNode!
    var sortingMethod: sortingStyles = .top

    let loadQueueSize = 2
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        buttonImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height)
        buttonImageView.addTarget(self, action: "nextPhotoButton:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonImageView.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        buttonImageView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(buttonImageView)
        self.view.sendSubviewToBack(buttonImageView)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: "upVoteButtonPressed:")
        let downSwipe = UISwipeGestureRecognizer(target: self, action: "downVoteButtonPressed:")
        
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        
        
        //playerLayer = CALayer()
        
        //buttonImageView.layer.addSublayer(playerLayer)
        
        setupImagesFromServer()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if currentImageViewNode?.medType == mediaType.video{
            playerLayer?.player?.play()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if currentImageViewNode?.medType == mediaType.video{

            playerLayer?.player?.pause()
        }
    }
        
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        hideAllButtons(false)
    }


    

    func bringUpTopImage(){
        if nextImageViewNode != nil{ // TODO Design What happens with Nil ImageView
            currentImageViewNode = nextImageViewNode!
            currentImageViewNode.delegate = self
            currentImageViewNode.isCurrentMediaNode = true
            nextImageViewNode = imageViewQueue.deQueue()
            nextImageViewNode?.downloadTopImage()
            
            
            switch currentImageViewNode.status{
            case .complete:
                updateTopNode()
            case .loading:
                // todo !!! Loading default
                print("loading image")
            case .failed:
                // todo !!! failed defualt
                print("failed to load image")
            }
        }
    
    }
    
    func updateTopNode(){
        if let type = currentImageViewNode?.medType{
            switch type{
            case .image:
                updateTopImage()
            case .video:
                updateTopVideo()
            }
        }
    }
    
    func updateTopImage(){
        
        if let data = currentImageViewNode?.mediaData{
              playerLayer?.removeFromSuperlayer()
              setImageForAllStates(UIImage(data: data))
            
            
            
            let votes = currentImageViewNode?.votes
            votesLabel.text = String(votes!)
            setVoteColor()
        }
    }
    
    func setImageForAllStates(image: UIImage?){
        buttonImageView.setImage(image, forState: UIControlState.Normal)
        buttonImageView.setImage(image, forState: UIControlState.Highlighted)
        buttonImageView.setImage(image, forState: UIControlState.Disabled)
    }
    
    func updateTopVideo(){
        if let data = currentImageViewNode?.mediaData{
            print(buttonImageView.layer.sublayers?.count)
            
            let URL = currentImageViewNode.pathToDownloadedMedia.currentVideoURL
            setImageForAllStates(nil)
            
            
            let player2 = AVPlayer(URL: URL)
            let plLayer = AVPlayerLayer(player: player2)
            plLayer.frame = buttonImageView.bounds
            plLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "loopVideo:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: self.playerLayer?.player?.currentItem)
            
            playerLayer?.removeFromSuperlayer()
            playerLayer = plLayer
            buttonImageView.layer.addSublayer(playerLayer)
            
            print(buttonImageView.layer.sublayers?.count)
            player2.play()

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
    
    
    func mediaTypeFromString(string: String) -> mediaType{
        if string == "image"{
            return mediaType.image
        } else if string == "video"{
            return mediaType.video
        } else{
            print("Something is wrong")
            return mediaType.image
        }
    }
    
    
    func deSerializeJson(data: NSData?){
        var loadPathNum = 0;
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
                        let dataType = snippet["mediaType"] as! String
                        let mType = mediaTypeFromString(dataType)
                        loadPathNum = loadQueueSize % (loadPathNum + 1)
                        imageViewQueue.enQueue((mediaNode(medURL: imageURL, idNum: id!, rankNum: rank!, votesNum: votes!, upVoted: upVoted, downVoted: downVoted, mType: mType, loadPN: String(loadPathNum))))
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
        imageViewQueue = Queue<mediaNode>()
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
    
    
    
    func setupButtons(){
        //refreshButton.titleLabel?.hidden = true
        //var image = UIImage(named: "RefreshButton")
        //image.size = CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)
        //refreshButton.setImage(image, forState: .Normal)
    }
    
    func loopVideo(notification: NSNotification) {
        self.playerLayer.player?.seekToTime(kCMTimeZero)
        self.playerLayer.player?.play()
    }
    

    
}










