//
//  userLocationClass.swift
//  CameraExample
//
//  Created by Ryan Knauer on 9/15/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

//let User = "ryan"
//let Password = "asdf1234"
//let credentialData = "\(User):\(Password)".dataUsingEncoding(NSUTF8StringEncoding)!
//let base64Credentials = credentialData.base64EncodedStringWithOptions([])
//let headers = ["Authorization": "Basic \(base64Credentials)"]


class userClass: NSObject, CLLocationManagerDelegate{
    var userName: String!
    private var password: String!
    var credentialData: NSData!
    var base64Credentials: String!
    var headers: [String : String]!
    var latitude: String?
    var longitude: String?
    var locationManager: CLLocationManager?
    var authToken : String?
    
    init(username: String, pswd: String){
        userName = username
        password = pswd
        credentialData = "\(userName):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        base64Credentials = credentialData.base64EncodedStringWithOptions([])
        headers = ["Authorization": "Basic \(base64Credentials)"]
        super.init()
        print("init called")
        self.updateCords()
        }
    
    
    func updateCords(){
        setupLocationManager()
        switch CLLocationManager.authorizationStatus(){
        case .Denied:
            print("access denied")
        case .Restricted:
            print("access restricted")
        case .NotDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse:
            if #available(iOS 9.0, *) {
                locationManager?.requestLocation()
            } else {
                locationManager?.startUpdatingLocation()
            }
        default: break
            //todo
        }
    }
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        if let lat = manager.location?.coordinate.latitude{
            self.latitude = String(format:"%.2f", lat)
        }
        if let lon = manager.location?.coordinate.longitude{
            self.longitude = String(format:"%.2f", lon)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        print("unable to find location")
        latitude = nil
        longitude = nil
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("hi")
    }
    
    
    func getToken(){
        let paramaters = [
            "username" : self.userName,
            "password" : self.password
        ]
        let URL = baseHTTPURL + "get-token/"
        Alamofire.request(.POST,  URL, parameters: paramaters)
            .validate().responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result.value)   // result of response serialization
                
                switch response.result{
                case .Success(let data):
                    self.parseToken(response.data)
                case .Failure(let error):
                    // !!! Figure out why!
                    print("userDNE")
                }
        
        }
    
    }
    
    func verifyToken() -> Bool{
        // !!! return if token is still valid or not
        return true 
    }
        
        
    func parseToken(Data : NSData?){
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(Data!, options: .AllowFragments)
            self.authToken = JSON["token"] as! String
        } catch {
            // !!! catch json error
        }
    }
    
}




