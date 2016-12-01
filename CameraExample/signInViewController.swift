//
//  signInViewController.swift
//  CameraExample
//
//  Created by Ryan Knauer on 11/14/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import Alamofire


class signInViewController: UIViewController, UITextFieldDelegate {
    

    
    var usernameField : userAndPasswordField!
    var passwordField : userAndPasswordField!
    var secondPasswordField : UITextField!
    var signInButton = UIButton()
    var signUpButton = UIButton()
    var signUpPressed : Bool = false
    
    var spaceBetweenFields : CGFloat!
    var usernameFieldWidth : CGFloat!
    var usernameFieldHeight : CGFloat!
    var totalShift : CGFloat!
    var currentField : UITextField? = nil
    let minSpaceBetweenKeyboardAndTextField : CGFloat = 70
    
    var currentButtonsAndTextFields : [UIControl] = []
    var currentButtons : [UIButton] = []
    var currentTextFields : [UITextField] = []
    var responseLabel : UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = popOverOpaqueBackgroundColor
        self.view.opaque = false
        
            spaceBetweenFields = 18
            usernameFieldWidth = view.frame.width / 1.5
            usernameFieldHeight = 45.0
            totalShift = spaceBetweenFields + usernameFieldHeight
        let usernameFieldX = (view.frame.width / 2) - (usernameFieldWidth / 2)
        let usernameFieldY = view.frame.height * (1/3)
        let passwordFieldY = usernameFieldY + totalShift
        let SIButtonY = passwordFieldY + totalShift
        let SIButtonWidth = (usernameFieldWidth / 2) - 5
        let SIButtonHeight = usernameFieldHeight + 10
        let SUButtonX = usernameFieldX + usernameFieldWidth - SIButtonWidth
        
        
        usernameField = userAndPasswordField(frame: CGRect(x: usernameFieldX, y: usernameFieldY, width: usernameFieldWidth, height: usernameFieldHeight))
        passwordField = userAndPasswordField(frame: CGRect(x: usernameFieldX, y: passwordFieldY, width: usernameFieldWidth, height: usernameFieldHeight))
        secondPasswordField = userAndPasswordField(frame: passwordField.frame.moved(0, dY: totalShift))
        usernameField.placeholder = "username"
        passwordField.placeholder = "password"
        secondPasswordField.placeholder = "password"
        usernameField.returnKeyType = UIReturnKeyType.Default
        passwordField.returnKeyType = UIReturnKeyType.Done
        secondPasswordField.returnKeyType = UIReturnKeyType.Done
        passwordField.secureTextEntry = true
        secondPasswordField.secureTextEntry = true
        
        
        signInButton.frame = CGRect(x: usernameFieldX, y: SIButtonY, width: SIButtonWidth, height: SIButtonHeight)
        signUpButton.frame = CGRect(x: SUButtonX, y: SIButtonY, width: SIButtonWidth, height: SIButtonHeight)
        
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        signInButton.backgroundColor = upVoteColor
        signUpButton.backgroundColor = baseColor
        
        signInButton.addTarget(self, action: "signIn:", forControlEvents:  UIControlEvents.TouchUpInside)
        signUpButton.addTarget(self, action: "signUp:", forControlEvents:  UIControlEvents.TouchUpInside)
        
        usernameField.delegate = self
        passwordField.delegate = self
        secondPasswordField.delegate = self
        
        
        secondPasswordField.hidden = true
        
        currentButtons = [signUpButton, signInButton]
        currentTextFields = [usernameField, passwordField, secondPasswordField]
        
        responseLabel = UILabel()
        responseLabel.frame = usernameField.frame.moved(0, dY: 0 - totalShift)
        responseLabel.textColor = UIColor.whiteColor()
        responseLabel.textAlignment = NSTextAlignment.Center
        responseLabel.text = "Please Sign In"
    
        
        
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(secondPasswordField)
        view.addSubview(responseLabel)

        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    
    }
    
    override func viewWillAppear(animated: Bool) {
        //CATransaction.begin()
        self.slideInAnimation(usernameField, inFrom: screenSide.left, slideOut: false)
        self.slideInAnimation(passwordField, inFrom: screenSide.right, slideOut: false)
        self.slideInAnimation(signInButton, inFrom: screenSide.left, slideOut:  false)
        self.slideInAnimation(signUpButton, inFrom: screenSide.right, slideOut:  false)
        //CATransaction.commit()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField === usernameField{
            print("textFieldReturned")
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }else if textField === passwordField{
            if signUpPressed{
                textField.resignFirstResponder()
                secondPasswordField.becomeFirstResponder()
            }else{
                textField.endEditing(false)
            }
            
        } else if textField === secondPasswordField{
            textField.endEditing(false)
        }
        return false
    }
    
    func signIn(sender: AnyObject?){
        if signUpPressed{
            passwordField.returnKeyType = UIReturnKeyType.Done
            signInButton.setTitle("Sign In", forState: UIControlState.Normal)
            backToSignIn()
            signUpPressed = false
        }else{
            //signIn
        }
    }
    
    func signUp(sender: AnyObject?){
        if signUpPressed{
            responseLabel.text = "..."
            currentButtonsAndTextFields.map{button in button.enabled = false}
            register()

        }
        else{
            passwordField.returnKeyType = UIReturnKeyType.Default
            signInButton.setTitle("Cancel", forState: .Normal)
            bringSignUpUp()
            signUpPressed = true
        }
    }
    
    func bringSignUpUp(){
        CATransaction.begin()
        CATransaction.setValue(false, forKey: "kCATransactionDisableActions")
        self.slideInAnimation(secondPasswordField, inFrom: screenSide.right, slideOut: false)
        signInButton.frame.origin.y += totalShift
        signUpButton.frame.origin.y += totalShift
        CATransaction.commit()
    }
    
    
    func backToSignIn(){
        self.slideInAnimation(secondPasswordField, inFrom: screenSide.left, slideOut: true)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(slideIOAnimationDuration*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.signInButton.frame.origin.y -= self.totalShift
            self.signUpButton.frame.origin.y -= self.totalShift
        })

        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(), curField = currentField {
            if view.frame.origin.y == 0{
                let diffBetweenFieldAndKeyboard = (view.frame.height - keyboardSize.height) - (curField.frame.origin.y + curField.frame.height)
                if diffBetweenFieldAndKeyboard < minSpaceBetweenKeyboardAndTextField{
                    self.view.frame.origin.y -= minSpaceBetweenKeyboardAndTextField - diffBetweenFieldAndKeyboard
                }
            }
            else {
                
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
                
            }
            else {
                
            }
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        currentField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        currentField = nil
    }
    
    func register(){
        if let pswd1 = passwordField.text, pswd2 = secondPasswordField.text, username = usernameField.text{
            if pswd1 == pswd2{
                let paramaters = ["username" : username, "password" : pswd1]
                let URL =  baseHTTPURL + "register/"
                Alamofire.request(.POST,  URL, parameters: paramaters)
                    .validate().responseJSON { response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result.value)   // result of response serialization
                        
                        switch response.result{
                        case .Success(let data):
                            self.registrationSuccessfull()
                        case .Failure(let error):
                            print("failure")
                            self.registrationFailed()
                        }
                        
                }
            }
            
    } else{
            
        }
    }
    
    func registrationSuccessfull(){
        responseLabel.text = "Success, Please Sign In"
        currentButtonsAndTextFields.map{$0.enabled = true}
        currentTextFields.map{ $0.text = nil}
        signIn(nil) // calls cancel button to go to sign in view
        
    }
    
    
    func registrationFailed(){
        responseLabel.text = "Failure, Please Try Again"
    }

}

extension CGRect{
    
    func moved(dX: CGFloat, dY: CGFloat) -> CGRect{
        return CGRect(x: self.origin.x + dX, y: self.origin.y + dY, width: width, height: height)
    }

    

}






