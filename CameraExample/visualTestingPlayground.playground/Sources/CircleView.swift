//
//  CircleView.swift
//  CameraExample
//
//  Created by Ryan Knauer on 10/17/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit



import UIKit

public class CircleView: UIView {
    
    let numberOfRectangles = UInt(54)
    let rectangleSize = CGSize(width:3, height:15)
    let animationDuration = NSTimeInterval(5.0)
    
    let rotateKey = "rotateKey"
    let rotateAndShrinkKey = "rotateAndShrink"
    let expandKey = "expandKey"
    var baseLayerSize : CGSize!
    
    let strokeColor = UIColor.blueColor()
    let inactiveColor = UIColor.whiteColor()
    
    let shapeLayer = CAShapeLayer()
    let drawLayer = CAShapeLayer()
    let opaqueLayer = CAShapeLayer()
    let outerRingLayer = CAShapeLayer()
    
    var startingFrame : CGRect!
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        startingFrame = frame
        baseLayerSize = layer.frame.size
        
        commonSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//     required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        startingFrame = frame
//        baseLayerSize = layer.frame.size
//        commonSetup()
//    }
    
    
    func getMask(size:CGSize, teethCount:UInt, teethSize:CGSize, radius:CGFloat) -> CGPathRef? {
        
        let halfHeight = size.height*0.5
        let halfWidth = size.width*0.5
        let deltaAngle = CGFloat(2*M_PI)/CGFloat(teethCount);
        
        let p = CGPathCreateWithRect(CGRectMake(-teethSize.width*0.5, radius, teethSize.width, teethSize.height), nil)
        
        let returnPath = CGPathCreateMutable()
        
        for i in 0..<numberOfRectangles {
            let translate = CGAffineTransformMakeTranslation(halfWidth, halfHeight)
            var rotate = CGAffineTransformRotate(translate, deltaAngle*CGFloat(i))
            CGPathAddPath(returnPath, &rotate, p)
        }
        
        return CGPathCreateCopy(returnPath)
    }
    
    
    func commonSetup() {
        
        
        self.backgroundColor = UIColor.clearColor()
        
        shapeLayer.path = getMask(frame.size, teethCount: numberOfRectangles, teethSize: rectangleSize, radius: ((frame.width*0.5)-rectangleSize.height))
        
        let halfWidth = frame.size.width*0.5
        let halfHeight = frame.size.height*0.5
        let halfDeltaAngle = CGFloat(M_PI/Double(numberOfRectangles))
        
        drawLayer.path = UIBezierPath(arcCenter: CGPointMake(halfWidth, halfHeight), radius: halfWidth, startAngle: CGFloat(-M_PI_2)-halfDeltaAngle, endAngle: CGFloat(M_PI*1.5)+halfDeltaAngle, clockwise: true).CGPath
        drawLayer.frame = frame
        
        drawLayer.fillColor = inactiveColor.CGColor
        drawLayer.strokeColor = UIColor.redColor().CGColor
        drawLayer.lineWidth = rectangleSize.height * 2
        drawLayer.strokeEnd = 0
        drawLayer.mask = shapeLayer
        
        outerRingLayer.path = UIBezierPath(arcCenter: CGPointMake(halfWidth, halfHeight),
            radius: halfWidth - (rectangleSize.height / 2), startAngle: 0, endAngle: CGFloat(M_PI*2.0), clockwise: true).CGPath
        
        let white = UIColor.whiteColor()
        let alpha = white.colorWithAlphaComponent(0.3)
        
        outerRingLayer.lineWidth = rectangleSize.height
        outerRingLayer.strokeColor = white.colorWithAlphaComponent(0.4).CGColor
        outerRingLayer.strokeEnd = 1.0
        outerRingLayer.fillColor = UIColor.clearColor().CGColor
        
        opaqueLayer.path = UIBezierPath(arcCenter: CGPointMake(halfWidth, halfHeight), radius: halfWidth - rectangleSize.height, startAngle: 0, endAngle: CGFloat(M_PI*2.0), clockwise: true).CGPath
        

        opaqueLayer.fillColor = alpha.CGColor
        
        
        layer.addSublayer(outerRingLayer)
        layer.addSublayer(opaqueLayer)
        layer.addSublayer(drawLayer)
        
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
    
    
    func animateCircle(duration: NSTimeInterval, from: CGFloat, to: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        drawLayer.strokeEnd = to
        self.drawLayer.addAnimation(animation, forKey: "strokeAnimation")
        }
    
    
    public func rotateCircleView(duration: CFTimeInterval = 1.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        
        self.layer.addAnimation(rotateAnimation, forKey: rotateKey)
    }
    
    
    
    
    
    func stopRotate(){
        if self.layer.animationForKey(rotateKey) != nil {
            self.layer.removeAnimationForKey(rotateKey)
        }
    }
    
    
    public func shrinkCircleView(duration: CFTimeInterval = 1.0, to: Double) {
        
        print("shrinking \(to)")
        let from = self.getCurrentAnimationScale()
        let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
        shrinkAnimation.additive = true
        shrinkAnimation.fromValue = from - to
        shrinkAnimation.toValue = 0
        shrinkAnimation.duration = duration
        shrinkAnimation.removedOnCompletion = true
        
        
        let scaleTransform = CATransform3DMakeScale(CGFloat(to), CGFloat(to), 1.0)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.transform = scaleTransform
        CATransaction.commit()
        print(getCurrentAnimationScale())
        
        layer.addAnimation(shrinkAnimation, forKey: "shrinkAnimation")
    
    }
    
    
    func expandCircleView(duration: CFTimeInterval = 1.0) {
        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.fromValue = 1.0
        expandAnimation.toValue = 1.2
        expandAnimation.duration = duration
        
        
        self.layer.addAnimation(expandAnimation, forKey: expandKey)
    }
    
    func stopExpand(){
        if self.layer.animationForKey(expandKey) != nil {
            self.layer.removeAnimationForKey(expandKey)
        }
    }
    
    func rotateAndShrinkCircleView(expandTime: CFTimeInterval = 1.0, rotateDuration: CFTimeInterval = 1.0, shrinkDuration: CFTimeInterval = 1.0){
        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.additive = true
        expandAnimation.fromValue = CGFloat(-0.2)
        expandAnimation.toValue = CGFloat(0.0)
        expandAnimation.duration = expandTime
        expandAnimation.removedOnCompletion = true
        
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.beginTime = expandTime
        rotateAnimation.duration = rotateDuration
        rotateAnimation.repeatCount = Float.infinity
        
        let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
        shrinkAnimation.additive = true
        shrinkAnimation.fromValue = 1.2
        shrinkAnimation.toValue = 0.8
        shrinkAnimation.beginTime = expandTime
        shrinkAnimation.duration = shrinkDuration
        
    
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [ rotateAnimation]
        animationGroup.duration = shrinkDuration + expandTime
        self.layer.addAnimation(animationGroup, forKey: rotateAndShrinkKey)
        
    }
    
    func stopRotateAndShrink(){
        if self.layer.animationForKey(rotateAndShrinkKey) != nil {
            self.layer.removeAnimationForKey(rotateAndShrinkKey)
        }
    }
    

    func getCurrentAnimationScale() -> Double{
        var scale : CGFloat = 1
        var width : CGFloat
        if let temp = self.layer.presentationLayer()?.bounds.width{
            width = temp
        } else{
            width = self.layer.frame.width
        }
        scale = width / baseLayerSize.width
        return Double(scale)
    }
    

    
    func reset(addAnimation: Bool){
        self.layer.removeAllAnimations()
        drawLayer.removeAllAnimations()
        
        if addAnimation{
            self.animateCircle(0.7, from: 0.7, to: 0)
        }
        
        setLayerScale(1.0)
        
    }
    
    
    func setLayerScale(Scale: CGFloat){
        
        //let mappedScale = CGFloat(Scale / getCurrentAnimationScale())
        
        
        
        let scaleTransform = CATransform3DMakeScale(Scale, Scale, 1.0)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.transform = scaleTransform
        CATransaction.commit()
        print(getCurrentAnimationScale())
    }
    
    func startTakingPictureAnimations(expandDur: Double, shrinkDur: Double){
        rotateCircleView(6.0)
        animateCircle(expandDur, from: 0, to: 1)
        //shrinkCircleView(expandDur, to: 1.2)
        //self.rotateAndShrinkCircleView(expandDur, rotateDuration: 6.0, shrinkDuration: shrinkDur)

    }
    

    
}