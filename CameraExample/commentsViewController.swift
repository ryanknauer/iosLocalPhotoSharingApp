//
//  commentsViewController.swift
//  CameraExample
//
//  Created by Ryan Knauer on 9/2/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import Alamofire

class commentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var sendButtonPressed: UIButton!

    @IBOutlet var bottomCommentView: UIView!
    
    @IBOutlet var messagesTable: UITableView!
    
    @IBOutlet var sendComment: UIButton!
    
    @IBOutlet var textFieldComment: UITextField!

    var messagesArray: [String]! = []
    
    var snippetID = "9"
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);

        
        
        self.view.backgroundColor = popOverOpaqueBackgroundColor
        self.messagesTable.backgroundColor = popOverOpaqueBackgroundColor
        
        updateArray()
        self.messagesTable.delegate = self
        self.messagesTable.dataSource = self
        print(messagesArray)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
                
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateArray(){
        let URL = baseHTTPURL + "comments/" + snippetID + "/"
        Alamofire.request(.GET,  URL, headers: User.headers)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                self.deSerializeJSON(response.data)
                
        }
    }
    
    
    func deSerializeJSON(data: NSData?){
        messagesTable.beginUpdates()
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let comments = JSON as? [[String: AnyObject]] {
                let lena = comments.count
                let lenb = messagesArray.count
                if lena > lenb{
                    let newComments = comments[lenb..<lena]
                    print(newComments)
                    for comment in newComments{
                        let owner = comment["owner"] as? String
                        let textComment = comment["comment"] as? String
                        let field = owner! + ":  " + textComment!
                        messagesArray.append(field)
                        messagesTable.insertRowsAtIndexPaths([NSIndexPath(forRow: messagesArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
                    }

                }
            }
        }
            
        catch{
            print("Json Error: \(error)")
        }
        messagesTable.endUpdates()

        // scrolltobottom
        if messagesArray.count > 0{
            let indexPath = NSIndexPath(forRow: messagesArray.count-1, inSection: 0)
            messagesTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom,
                animated: true)
        }
    }

    

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.messagesTable.dequeueReusableCellWithIdentifier("MessagesCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = messagesArray[indexPath.row]
        return cell
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        if let comment = textFieldComment.text{
            sendComment.enabled = false
            let params: [String:AnyObject] = [
                "comment" : comment
            ]
            let URL =  baseHTTPURL + "comments/" + snippetID + "/"
            Alamofire.request(.POST, URL, headers: User.headers, parameters: params)
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)
                    switch response.result{
                    case .Success:
                        self.succussfullyAddedComment(comment)
                    case .Failure:
                        self.failedToAddComment()
                    }
                    
            }
        }
        
    }
    
    func succussfullyAddedComment(comment: String){
//        messagesTable.beginUpdates()
//        fullComment = User + ":  "
//        messagesArray.append(comment)
//        messagesTable.insertRowsAtIndexPaths([NSIndexPath(forRow: messagesArray.count-1, inSection: 0)], withRowAnimation: .Automatic)
//        messagesTable.endUpdates()
        updateArray()
        textFieldComment.text = ""
        sendComment.enabled = true
        
    }
    
    func failedToAddComment(){
        sendComment.enabled = true
        print("failedToAddComment")
        //!!!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.bottomCommentView.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        bottomCommentView.endEditing(true)
    }
    
    
    


    
}
