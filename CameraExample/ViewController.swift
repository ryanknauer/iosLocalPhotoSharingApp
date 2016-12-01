//
//  ViewController.swift
//  CameraExample
//
//  Created by Ryan Knauer on 7/6/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AssetsLibrary



class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var captureSession = AVCaptureSession()
    
    var captureDevice: AVCaptureDevice?
    
    var deviceInput: AVCaptureInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var videoOutput: AVCaptureMovieFileOutput?
    
    var videoDelegate : AVCaptureFileOutputRecordingDelegate?
    
    var capturedImage : UIImage?
    
    var imageData : NSData?
    
    var player : AVPlayer?
    
    var playerLayer : AVPlayerLayer?
    
    var error : NSError?
    
    var medType : mediaType!
    
    var circleView : CircleView!
    
    let videoMaxTimeInSeconds : Double = 8.0
    
    let videoOrImageDelayInMSec : UInt64 = 500
    
    let minVideoLengthInSeconds : Double = 1.0
    
    let circleSize : CGSize = CGSize(width: 30.0, height: 30.0)
    
    @IBOutlet var uploadedLabel: UILabel!
   
    var takenImageView: UIImageView = UIImageView()
  
    @IBOutlet var flipButton: UIButton!
    
    var capturePhotoButton = UIButton(type: UIButtonType.Custom) as UIButton
    
    @IBOutlet var cancelPhotoButton: UIButton!
    
    @IBOutlet var uploadPhotoButton: UIButton!

    
    var doubleTapToFlip: UITapGestureRecognizer!
    
    let videoData: videoClass = videoClass(string: "upload")
    
    var takingVideo: Bool = false
    
    var camera = CameraType.back
    
    var startTakingVideoBlock: dispatch_block_t!
    
    var videoTimedOutBlock: dispatch_block_t!
    
    var videoTooShort : Bool = true

    var downTapGestureRecognizer : UIGestureRecognizer!
    
    var upTapGestureRecognizer : UIGestureRecognizer!
    
    var isButtonShrunk : Bool? = false
    
    
    
    var capturePhotoButtonCenter : CGPoint!
    var offsetX : CGFloat!
    var offsetY : CGFloat!
    var sequeToSignIn : UIStoryboardSegue!
    var signedIn = false
    
    enum CameraType {
        case front
        case back
    }
    
    
    let photoCaptureButton: UIButton! = UIButton(type: UIButtonType.Custom) as UIButton
    
    var takingButtonsArray : [UIButton]!
    var takenButtonsArray : [UIButton]!
    var currentButtons : [UIButton] = []
    
    func testButtonTest(sender: AnyObject){
        print("tested")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        takingButtonsArray = [capturePhotoButton, flipButton]
        takenButtonsArray = [uploadPhotoButton, cancelPhotoButton]
        currentButtons = takingButtonsArray
        
        User = userClass(username: "ryan", pswd: "asdf1234")
        
        //setup flip camera gesture rec.
        doubleTapToFlip = UITapGestureRecognizer(target: self, action: "flipPressed:")
        doubleTapToFlip.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapToFlip)

        
        videoDelegate = self
        
        setupButtons()
        
        self.view.backgroundColor = UIColor.blackColor()
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        takenImageView.frame = CGRectMake(0, 0, frameWidth, frameHeight)
        takenImageView.bounds = CGRectMake(0, 0, frameWidth, frameHeight)
        //self.view.clipsToBounds = true
        //self.view.layer.masksToBounds = true
        takenImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(takenImageView)
        self.view.sendSubviewToBack(takenImageView)

        
        selectBackCamera()
        hideTakenPictureView(true)
        uploadedLabel.hidden = true
        beginSession()
        
        


        
    }
    


    

    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()){
            if (!self.signedIn){
                self.bringUpSignIn()
            }
        }
    }
    
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        for b in currentButtons { slideInAnimation(b, inFrom: closestEdge(b), slideOut: false)}
    }
    
    
    func bringUpSignIn(){
        performSegueWithIdentifier("segueToSignIn", sender: nil)
    }
    
    func closestEdge(v : UIView) -> screenSide{
        let centerX = v.center.x
        let centerY = v.center.y
        let distToFarSide = self.view.frame.width - centerX
        let distToBottom = self.view.frame.height - centerY
        let distToTop = self.view.frame.height - distToBottom
        let distToNearSide = self.view.frame.width - distToFarSide
        switch min(distToTop, distToFarSide, distToBottom, distToNearSide){
        case distToTop:
            return screenSide.top
        case distToBottom:
            return screenSide.bottom
        case distToFarSide:
            return screenSide.right
        case distToNearSide:
            return screenSide.left
        default:
            print("defualt shouldn't be hit!")
            return screenSide.right
        }
    }


    func stopRunningPreviewSession(){
         captureSession.stopRunning()
         previewLayer?.removeFromSuperlayer()
    }
    
    
    func beginSession(){
        //reset session
        stopRunningPreviewSession()
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        print(captureDevice)
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            if (captureSession.canAddInput(deviceInput) == true){
                captureSession.addInput(deviceInput)
            }
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession.canAddOutput(stillImageOutput) == true){
                captureSession.addOutput(stillImageOutput)
            }
            
            videoOutput = AVCaptureMovieFileOutput()
            
            
            if (captureSession.canAddOutput(videoOutput) == true){
                captureSession.addOutput(videoOutput)
            } else{
                //todo!!!
                print("couldn't add video output")
            }
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
        setupPreview()
        view.layer.insertSublayer(previewLayer!, atIndex: 0)
        captureSession.startRunning()
        
    }
    
    
    func videoTaken() {
        videoData.clearCurrentVideoPath()
        
        videoTimedOutBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS){
            if self.takingVideo{
                self.photoButtonPressed(nil)
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(videoMaxTimeInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), videoTimedOutBlock)
        
        self.videoOutput?.startRecordingToOutputFileURL(videoData.currentVideoURL, recordingDelegate: videoDelegate)

    }
    
    func videoEnded(){
        // hide background buttons and preview
        hidePreviewView(true)
        hideTakenPictureView(false)
        
        
        
        
        
        self.videoOutput?.stopRecording()
    }
    
    
    
    func pictureTaken() {
    
        print(captureDevice!.adjustingFocus)
        if let imageConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(imageConnection, completionHandler: {
                (sampleBuffer, error1) in
                if error1 != nil{
                    print("error1 is! nil")
                } else if (sampleBuffer != nil){
                    let imageJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    //Test!!! upload to server
                    self.medType = mediaType.image
                    
                    self.imageData = imageJpeg
                    
                    self.capturedImage = UIImage(data: imageJpeg)
                    
                    self.takenImageView.image = self.capturedImage
                    
                    
                    
                } else {
                    // TODO!!! Handle error when no picture grabbed
                }
            })
        }
        
        //set buttons & end preview
        hidePreviewView(true)
        hideTakenPictureView(false)
        
        stopRunningPreviewSession()
    }
    
    
    
    func setupPreview() {
        let preview =  AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview.position = CGPoint(x: CGRectGetMidX(self.view.bounds), y: CGRectGetMidY(self.view.bounds))
        preview.videoGravity = AVLayerVideoGravityResize
        previewLayer = preview
    }
    
    
    
    
    func selectFrontCamera(){
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices{
            let device = device as! AVCaptureDevice
            if (device.position == AVCaptureDevicePosition.Front){
                captureDevice = device
            }
        }
    }
    
    
    
    
    func selectBackCamera(){
        captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }
    
    
    
    
    
    @IBAction func flipPressed(sender: AnyObject) {
       
        if(camera == CameraType.back){
            selectFrontCamera()
            camera = CameraType.front
        }else if (camera == CameraType.front){
            selectBackCamera()
            camera = CameraType.back
        }
        beginSession()
    }
    
    
    func photoButtonPressed(sender: AnyObject?) {
        if takingVideo{
            
            takingVideo = false


            dispatch_block_cancel(videoTimedOutBlock)
            
            
            videoEnded()
        }else{
            
            if startTakingVideoBlock != nil {
                dispatch_block_cancel(startTakingVideoBlock)
            }
            
            takingVideo = false
            if captureDevice!.adjustingFocus == true{
                self.captureDevice!.addObserver(self, forKeyPath: "adjustingFocus", options: .New, context: nil)
            } else{
                pictureTaken()
            }
        }
        
    }
    
    func touchUpOutsidePressed(sender: AnyObject) {
        photoButtonPressed(sender)
    }
    
    func touchDownPhotoButton(sender: AnyObject) {
        takingVideo = false
        let expandDur = Double(self.videoOrImageDelayInMSec) / 1000.0
        self.circleView.startTakingPictureAnimations(expandDur, shrinkDur: videoMaxTimeInSeconds + 1)
        let videoNoLongerTooShortBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            self.videoTooShort = false
        }
        
        startTakingVideoBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            self.takingVideo = true
            self.videoTooShort = true
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.minVideoLengthInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), videoNoLongerTooShortBlock)
            self.videoTaken()
        }
        
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(videoOrImageDelayInMSec * NSEC_PER_MSEC)), dispatch_get_main_queue(), startTakingVideoBlock)
    }
    

    @IBAction func uploadButtonPressed(sender: AnyObject) {
        self.uploadImageAndData()
        backToSession()
        uploadedLabel.hidden = false
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1 ), target: self, selector: "hideUploadedLabel", userInfo: nil, repeats: false)
    }
    
    func hideUploadedLabel() {
        self.uploadedLabel.hidden = true
    }
    
    
    @IBAction func goBackToSession(sender: AnyObject) {

        backToSession()
    }
    
    
    func backToSession(){
        resetCapturePhotoButton()
        if player != nil{
            stopPlayBackVideo()
        }
        beginSession()
        takenImageView.image = nil
        imageData = nil
        hidePreviewView(false)
        hideTakenPictureView(true)
        
    }
    
    func hidePreviewView(bool: Bool){
        capturePhotoButton.hidden = bool
        capturePhotoButton.enabled = !bool
        flipButton.hidden = bool
        if !bool{
            currentButtons = takingButtonsArray
        }
    }
    
    
    func resetCapturePhotoButton(){
        capturePhotoButton.center = capturePhotoButtonCenter
        circleView.reset(true)
        
        // add way to see if button animation ran fully keeps reset animation from "ressetting red" if no red showed in the first place
    }
    
    
    
    func hideTakenPictureView(bool: Bool){
        cancelPhotoButton.hidden = bool
        uploadPhotoButton.hidden = bool
        doubleTapToFlip.enabled = bool
        if !bool{
            currentButtons = takenButtonsArray
        }
//        if bool{
//            self.view.addGestureRecognizer(doubleTapToFlip)
//        }else{
//            self.view.removeGestureRecognizer(doubleTapToFlip)
//        }
        
    }
    
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "adjustingFocus"{
            pictureTaken()
            self.captureDevice!.removeObserver(self, forKeyPath: "adjustingFocus", context: nil)
        }
    }
    
    
    
    func uploadImageAndData(){
        var dataType: String
        var mimeType: String
        var fileName: String
        let data = imageData
        
        switch medType!{
        case mediaType.image:
            dataType = "image"
            mimeType = "image/jpeg"
            fileName = "testing.jpeg"
        case mediaType.video:
            dataType = "video"
            mimeType = "video/quicktime"
            fileName = "testing.mov"
        }
        
        
        var parameters = [String:String]()
        if let lat = User.latitude, lon = User.longitude{
            print(lat, lon)
            parameters = [
                "Latitude": "\(lat)",
                "Longitude": "\(lon)",
                "mediaType": "\(dataType)"
            ]
        } else{
            print("location not found!")
            //todo!!!
        }
        
        let URL = baseHTTPURL + "quickstart/"
 
        
        Alamofire.upload(.POST, URL, headers: User.headers, multipartFormData: {
            multipartFormData in
                multipartFormData.appendBodyPart(data: data!, name: "photo", fileName: fileName, mimeType: mimeType)
            
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                   }
            }, encodingCompletion: {
                encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })}
    
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("donerecording")
        
        // todo handle any error!!!
        if videoTooShort {
            print("videoTooShort")
            takingVideo = false
            photoButtonPressed(nil)
        }else{
            print("videoNotTooShort")
            imageData = NSData(contentsOfURL: outputFileURL)
            medType = mediaType.video
            playBackVideo(outputFileURL)
        }

    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("recording")
    }

    
    func playBackVideo(url: NSURL){
        stopRunningPreviewSession()
        
        
        player = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: player)
        let layerFrame = takenImageView.frame
        let layerBounds = takenImageView.bounds
        let layerPosition = takenImageView.layer.position
        playerLayer!.frame = layerFrame
        playerLayer!.bounds = layerBounds
        playerLayer!.position = layerPosition
        playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loopVideo:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.player!.currentItem)
        
        self.takenImageView.layer.addSublayer(playerLayer!)
        player?.play()
    }
    
    
    func stopPlayBackVideo() {
        if let _ = player{
            NSNotificationCenter.defaultCenter().removeObserver((self.player!.currentItem)!)
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            player = nil
        }

    }
    
    
    
    func numtoNSDATA(num: Double) -> NSData {
        var cord: Double = num
        let data = NSData(bytes: &cord, length: sizeof(Int))
        return data
    }
    
    
    
    
    func setupButtons(){
        //capturePhotoButton
        
        let heightAndWidth = view.frame.width / (3.0)
        let halfHW = heightAndWidth / 2
        let buttonFrame = CGRect(x: (view.frame.width / 2) - halfHW, y: view.frame.height - heightAndWidth - 20, width: heightAndWidth, height: heightAndWidth)
        
    
        
        
        
        let pan = UIPanGestureRecognizer(target: self, action: "moveButtonWithFinger:")
        
        capturePhotoButton.addGestureRecognizer(pan)
        
        capturePhotoButton.frame = buttonFrame
        capturePhotoButtonCenter = capturePhotoButton.center
        capturePhotoButton.backgroundColor = .clearColor()
        capturePhotoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        capturePhotoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: .TouchUpOutside)
        capturePhotoButton.addTarget(self, action: "touchDownPhotoButton:", forControlEvents: .TouchDown)
        //self.capturePhotoButton.addTarget(self, action: Selector("settingsButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(capturePhotoButton)
        
       // capturePhotoButton.setTitle(nil, forState: .Normal)
        let frame = CGRect(x: 0, y: 0, width:capturePhotoButton.frame.width, height:capturePhotoButton.frame.height)
        circleView = CircleView(frame: frame)
        circleView.userInteractionEnabled = false
        circleView.exclusiveTouch = false
        capturePhotoButton.addSubview(circleView)
    
        //capturePhotoButton.bringSubviewToFront(circleView)
        
    }
    
    func settingsButtonPressed(sender:UIButton!){
        print("Settings selected")
    }

    
    func loopVideo(notification: NSNotification) {
        self.player?.seekToTime(kCMTimeZero)
        self.player?.play()
    }
    
    
    
    func startCircleAnimationAtPoint(){
        
        circleView.rotateAndShrinkCircleView(6.0, shrinkDuration: self.videoMaxTimeInSeconds)
    }
    
    func moveButtonWithFinger(sender: UIPanGestureRecognizer) {
        switch sender.state{
            
        case .Began:
            print("panStarted")
            let panOffsetPoint = sender.locationInView(self.view)
            offsetX = capturePhotoButtonCenter.x - panOffsetPoint.x
            offsetY = capturePhotoButtonCenter.y - panOffsetPoint.y
        case .Ended:
            // move button back to center ideally TODO or hide button!!!
            self.photoButtonPressed(nil)
            isButtonShrunk = nil
            
        case .Changed:
            //circleView.printBounds()
            let point = sender.locationInView(self.view)
            let x = point.x + offsetX
            let y = point.y + offsetY
            let distanceFromCenter = distance(x, y: y, a: capturePhotoButtonCenter.x, b:  capturePhotoButtonCenter.y)
            
            if isButtonShrunk != nil{
                if isButtonShrunk!{
                    if distanceFromCenter <= 20 {
                        isButtonShrunk = false
                        circleView.shrinkCircleView(0.5, to: 1.2)
                    }

                }else {
                    if distanceFromCenter > 20 {
                        isButtonShrunk = true
                        let from = Double(circleView.getCurrentAnimationScale())
                        print(from)
                        print("\(isButtonShrunk) From:" + "\(from)")
                        circleView.shrinkCircleView(0.5, to: 0.67)
                    }
                    
                }
                
            } else{
                if distanceFromCenter > 20{
                    isButtonShrunk = false
                }
            }
            
            capturePhotoButton.center = CGPoint(x: x, y: y)
            
        default:
            print(sender.state)
            
        }
    }
    
    func distance(x: CGFloat, y: CGFloat, a: CGFloat, b: CGFloat) -> CGFloat{
        return sqrt(pow((x - a),2) + pow((y - b),2))
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToSignIn" || segue.identifier == "segueToUserInfo"{
            for b in currentButtons{
                slideInAnimation(b, inFrom: closestEdge(b), slideOut: true)
            }
            print("seguingtoSignIn")
        }
    }
    
}








