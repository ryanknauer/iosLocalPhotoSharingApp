//
//  videoClass.swift
//  CameraExample
//
//  Created by Ryan Knauer on 10/7/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation



class videoClass {
    var currentVideoURL: NSURL!
    
    init(string: String){
        setCurrentVideoPath(string)
    }
    
    func clearCurrentVideoPath(){
        do {
            try NSFileManager.defaultManager().removeItemAtURL(currentVideoURL)
        }
        catch{
            // TODO handle Error !!!
            
        }
    }
    

    
    func setCurrentVideoPath(string: String){
        // set temporary nsurl
        let fileName = String(format: "%@_%@", "videoURL" + string, "file.mov")
        currentVideoURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(fileName)

    }
    
}