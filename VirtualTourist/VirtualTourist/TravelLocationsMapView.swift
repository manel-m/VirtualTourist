//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Manel matougui on 9/1/18.
//  Copyright © 2018 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        if #available(iOS 8.0, *) {
//            locationManager.requestAlwaysAuthorization()
//        } else {
//            // Fallback on earlier versions
//        }
        locationManager.startUpdatingLocation()
        // add gesture recognizer
       
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapView.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        
        print("A long press has been detected.")
        
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = touchedAtCoordinate
        mapView.addAnnotation(newPin)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

