//
//  userInfoViewController.swift
//  CameraExample
//
//  Created by Ryan Knauer on 11/21/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit
import Foundation

class userInfoViewController: UIViewController {
    
    let signOutButton : UIButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = popOverOpaqueBackgroundColor
        self.view.opaque = false
        
        let sOBWidth = self.view.frame.width / 5
        let sOBHeight : CGFloat = 14.0
        let sOBX = self.view.frame.width * 0.8
        let sOBY : CGFloat = 30.0
        signOutButton.frame = CGRect(x: sOBX, y: sOBY, width: sOBWidth, height: sOBHeight)
        signOutButton.setTitle("Sign Out", forState: .Normal)
        signOutButton.addTarget(self, action: "signOutPressed:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(signOutButton)
    }
    
    
    func signOutPressed(){
        //!!! TODO sign out
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
}
