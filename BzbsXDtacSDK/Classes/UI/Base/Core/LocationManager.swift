//
//  LocationManager.swift
//  BzbsXDtacSDK
//
//  Created by apple on 18/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

enum EnumLocationManagerNotification: String {
    case updateLocation = "kNotificationLocationUpdate"
    
    var notification : Notification.Name  {
        return Notification.Name(rawValue: self.rawValue )
    }
}

class LocationManager: NSObject {
    
    static var shared: LocationManager! = LocationManager()
    
    var locationManager  = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var lastUpdate :Date?
    
    var authorizationStatus:CLAuthorizationStatus {
        CLLocationManager.authorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        if  CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func distanceFrom(_ coordinate:CLLocationCoordinate2D) -> String?{
        guard let currentCoordiante = self.coordinate else { return nil }
        let currentLocation = CLLocation(latitude: currentCoordiante.latitude, longitude: coordinate.longitude)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = currentLocation.distance(from: location) / 1000
        return String(format: "%.2f", distance)
    }
    
    func getCurrentCoorndate() -> String
    {
        if authorizationStatus == .authorizedWhenInUse
        {
            if let lat = coordinate?.latitude,
                let lon = coordinate?.longitude
            {
                return "\(lat),\(lon)"
            }
        }
        return "0.0,0.0"
    }
}

// MARK:- Extension
// MARK:- CLLocationManagerDelegate
extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if  status != .denied {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationObj = locations.last! as CLLocation
        if lastUpdate == nil {
            lastUpdate = Date()
            coordinate = locationObj.coordinate
            locationManager.stopUpdatingLocation()
            
            NotificationCenter.default.post(name: EnumLocationManagerNotification.updateLocation.notification, object: nil)
        }
        
        if Date().timeIntervalSince1970 - lastUpdate!.timeIntervalSince1970 > 60 * 5 {
            lastUpdate = Date()
            coordinate = locationObj.coordinate
            locationManager.stopUpdatingLocation()
            
            NotificationCenter.default.post(name: EnumLocationManagerNotification.updateLocation.notification, object: nil)
        }
    }
}
