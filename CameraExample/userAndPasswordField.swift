//
//  userAndPasswordField.swift
//  CameraExample
//
//  Created by Ryan Knauer on 11/16/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit

class userAndPasswordField: UITextField, UITextFieldDelegate{
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        self.borderStyle = UITextBorderStyle.RoundedRect
        self.autocorrectionType = UITextAutocorrectionType.No
        self.returnKeyType = UIReturnKeyType.Default
        self.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.delegate = self
    }

    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
