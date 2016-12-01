//
//  File.swift
//  CameraExample
//
//  Created by Ryan Knauer on 11/14/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation
import UIKit



var User : userClass!

let baseHTTPURL: String = "http://128.189.82.7:8000/" //"http://172.20.10.4:8000/" //"http://10.0.9.81:8000/" //"http://192.168.0.110:8000/" //"http://192.168.0.110:8000/" //"http://128.189.85.73:8000/" //"http://128.189.86.246:8000/" //"http://172.20.10.3:8000/"  //"http://192.168.0.110:8000/"   "http://192.168.0.110:8000/" 

let popOverOpaqueBackgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
let upVoteColor = UIColor.orangeColor()
let downVoteColor = UIColor.lightGrayColor()
let baseColor = UIColor(red: 0, green: 0.5216, blue: 0.9765, alpha: 1.0)
let slideIOAnimationDuration = 0.5

enum screenSide{
    case left
    case right
    case top
    case bottom
}


extension UIViewController{
    
    func slideInAnimation(animator: UIView, inFrom: screenSide, slideOut: Bool){
        var slideAnimation: CABasicAnimation
        var from : CGFloat
        var to : CGFloat
        let resetOrigin = animator.frame.origin
        animator.hidden = false
        CATransaction.commit()
        
        CATransaction.setCompletionBlock({
                animator.hidden = slideOut
                animator.frame.origin = resetOrigin
            })
        
        
        switch inFrom{
        case .top:
            slideAnimation = CABasicAnimation(keyPath: "position.y")
            from = 0 - (animator.frame.width / 2)
            to = animator.layer.position.y
        case .bottom:
            slideAnimation = CABasicAnimation(keyPath: "position.y")
            from = self.view.frame.height + (animator.frame.height / 2)
            to = animator.layer.position.y
        case .left:
            slideAnimation = CABasicAnimation(keyPath: "position.x")
            from = 0 - (animator.frame.width / 2)
            to = animator.layer.position.x
        case .right:
            slideAnimation = CABasicAnimation(keyPath: "position.x")
            from = self.view.frame.width + (animator.frame.width / 2)
            to = animator.layer.position.x
        }
        
        
        slideAnimation.duration = slideIOAnimationDuration
        if slideOut{
            slideAnimation.fromValue = Int(to)
            slideAnimation.toValue = Int(from)
        } else{
            slideAnimation.fromValue = Int(from)
            slideAnimation.toValue = Int(to)
        }

        slideAnimation.removedOnCompletion = true
        slideAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        

        animator.layer.addAnimation(slideAnimation, forKey: nil)
        CATransaction.begin()
        if slideOut{
            switch inFrom{
            case .top, .bottom:
                animator.layer.position.y = from
            case .right, .left:
                animator.layer.position.x = from
            }
        }
        
        
      
    }
    
}