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

var User : userClass!
let baseHTTPURL: String = "http://192.168.0.110:8000/" //"http://192.168.0.110:8000/" //"http://128.189.85.73:8000/" //"http://128.189.86.246:8000/" //"http://172.20.10.3:8000/"  //"http://192.168.0.110:8000/"   "http://192.168.0.110:8000/"

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
    
    let videoMaxTimeInSeconds : Double = 8
    
    @IBOutlet var uploadedLabel: UILabel!
   
    @IBOutlet var takenImageView: UIImageView!
  
    @IBOutlet var flipButton: UIButton!
    
    @IBOutlet var takePhotoButton: UIButton!
    
    @IBOutlet var cancelPhotoButton: UIButton!
    
    @IBOutlet var uploadPhotoButton: UIButton!
    
    @IBOutlet var takeVideoButton: UIButton!
    
    var doubleTapToFlip: UITapGestureRecognizer!
    
    let videoData: videoClass = videoClass(string: "upload")
    
    var takingVideo: Bool = false
    
    enum CameraType {
        case front
        case back
    }
    
    var camera = CameraType.back

    override func viewDidLoad() {
        super.viewDidLoad()
        
        User = userClass(username: "ryan", pswd: "asdf1234")
        
        doubleTapToFlip = UITapGestureRecognizer(target: self, action: "flipPressed:")
        doubleTapToFlip.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapToFlip)

        
        videoDelegate = self
        
        setupButtons()
        
        

        selectBackCamera()
        hideTakenPictureView(true)
        uploadedLabel.hidden = true
    
        beginSession()
    }
    

    
    override func viewDidAppear(animated: Bool) {
        
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
        self.videoOutput?.startRecordingToOutputFileURL(videoData.currentVideoURL, recordingDelegate: videoDelegate)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(videoMaxTimeInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            if self.takingVideo{
                self.takeVideoPressed(nil)
            }
        }
    }
    
    func videoEnded(){
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
        
        //set buttons & end preview3
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
    
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        
        if captureDevice!.adjustingFocus == true{
            self.captureDevice!.addObserver(self, forKeyPath: "adjustingFocus", options: .New, context: nil)
        } else{
            pictureTaken()
        }
        
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
        takePhotoButton.hidden = bool
        flipButton.hidden = bool
        takeVideoButton.hidden = bool
    }
    
    
    
    func hideTakenPictureView(bool: Bool){
        cancelPhotoButton.hidden = bool
        uploadPhotoButton.hidden = bool
        doubleTapToFlip.enabled = bool
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

        imageData = NSData(contentsOfURL: outputFileURL)
        medType = mediaType.video
        playBackVideo(outputFileURL)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("recording")
    }

    
    func playBackVideo(url: NSURL){
        // hide background buttons and preview
        
        hidePreviewView(true)
        hideTakenPictureView(false)
        stopRunningPreviewSession()
        
        player = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.view.bounds
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
    

    @IBAction func takeVideoPressed(sender: AnyObject?) {
        if takingVideo{
            takingVideo = false
            takeVideoButton.setTitle("TakeVideo", forState: UIControlState.Normal)
            videoEnded()
        }else {
            takingVideo = true
            takeVideoButton.setTitle("EndVideo", forState: UIControlState.Normal)
            videoTaken()

        }
        
    }
    
    
    func setupButtons(){
        //!!! SetupButtons
    }
    
    func loopVideo(notification: NSNotification) {
        self.player?.seekToTime(kCMTimeZero)
        self.player?.play()
    }
    
}








