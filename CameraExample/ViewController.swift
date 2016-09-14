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


class ViewController: UIViewController {

    
    var captureSession = AVCaptureSession()
    
    var captureDevice: AVCaptureDevice?
    
    var deviceInput: AVCaptureInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var videoOutput: AVCaptureVideoDataOutput?
    
    var capturedImage : UIImage?
    
    var imageData : NSData?
    
    var error : NSError?
    
    @IBOutlet var uploadedLabel: UILabel!
   
    @IBOutlet var takenImageView: UIImageView!
  
    @IBOutlet var flipButton: UIButton!
    
    @IBOutlet var takePhotoButton: UIButton!
    
    @IBOutlet var cancelPhotoButton: UIButton!
    
    @IBOutlet var uploadPhotoButton: UIButton!
    
    enum CameraType {
        case front
        case back
    }
    
    var camera = CameraType.back

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.videoSettings = nil
            
            if (captureSession.canAddOutput(videoOutput) == true){
                captureSession.addOutput(videoOutput)
            }
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
        setupPreview()
        view.layer.insertSublayer(previewLayer!, atIndex: 0)
        captureSession.startRunning()
        
    }
    
    
//    func videoTaken() {
//        if let videoConnection = videoOutput?.connectionWithMediaType(AVMediaTypeVideo){
//            
//        }
//    }
//    
    
    
    
    
    
    
    
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
                    
                    self.imageData = imageJpeg
                    
                    self.capturedImage = UIImage(data: imageJpeg)
                    
                    self.takenImageView.image = self.capturedImage
                    print(self.capturedImage)
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
        beginSession()
        takenImageView.image = nil
        imageData = nil
        hidePreviewView(false)
        hideTakenPictureView(true)
    }
    
    func hidePreviewView(bool: Bool){
        takePhotoButton.hidden = bool
        flipButton.hidden = bool
    }
    
    
    
    func hideTakenPictureView(bool: Bool){
        cancelPhotoButton.hidden = bool
        uploadPhotoButton.hidden = bool
    }
    
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "adjustingFocus"{
            pictureTaken()
            self.captureDevice!.removeObserver(self, forKeyPath: "adjustingFocus", context: nil)
        }
    }
    
    
    
    func uploadImageAndData(){

        let data = imageData
        var parameters = [String:String]()
        parameters = [
            "Latitude": "12.3",
            "Longitude": "12.54"
        ]
        
        let URL = "http://192.168.0.110:8000/quickstart/" //"http://127.0.0.1:8000/quickstart/"
 
        
        Alamofire.upload(.POST, URL, headers: headers, multipartFormData: {
            multipartFormData in
                multipartFormData.appendBodyPart(data: data!, name: "photo", fileName: "testing.jpeg", mimeType: "image/jpeg")
            
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
        })
        
    }
    
    func numtoNSDATA(num: Double) -> NSData {
        var cord: Double = num
        let data = NSData(bytes: &cord, length: sizeof(Int))
        return data
    }
    


    
}








