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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteLabel: UILabel!
    let locationManager = CLLocationManager()
    var editOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.doneButton.isHidden = true
        self.deleteLabel.text = ""
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
    @IBAction func editButton(_ sender: Any) {
        self.doneButton.isHidden = false
        self.deleteLabel.text = "Tap pins to delete"
        self.editButton.isEnabled = false
        editOn = true
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.doneButton.isHidden = true
        self.deleteLabel.text = ""
        self.editButton.isEnabled = true
        editOn = false
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect \(view)")
        if editOn {
            self.mapView.removeAnnotation(view.annotation!)
        } else {
            
        }
        
    }
    
}

