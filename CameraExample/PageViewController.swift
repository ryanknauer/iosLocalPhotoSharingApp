//
//  PageViewController.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/28/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([getViewController("cameraViewController")],
            direction: .Forward,
            animated: true,
            completion: nil)
       _ = getViewController("imagesViewController")
    }
    


    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let id = viewController.restorationIdentifier!
        switch id {
        case "cameraViewController":
            return getViewController("imagesViewController")
        case "imagesViewController":
            return nil
        default:
            return nil
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let id = viewController.restorationIdentifier!
        switch id {
        case "cameraViewController":
            return nil
        case "imagesViewController":
            return getViewController("cameraViewController")
        default:
            return nil
        }
    }
    
    
    
    
    func getViewController(Name: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Name)
    }
    

}
