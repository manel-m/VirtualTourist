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
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteLabel: UILabel!
    let locationManager = CLLocationManager()
    var editOn: Bool = false
    var dataController:DataController!
    var pins :[Pin] = []
    
    func createAnnotations() {
        for pin in pins {
            let annotation = PinAnnotation(pin)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.doneButton.isHidden = true
        self.deleteLabel.text = ""
        // setup Fetching
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            pins = results
            //reload  Data
            self.createAnnotations()
        }
        
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
        if (editOn || recognizer.state != .began) {
            return
        }
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        
        addPin(latitude: touchedAtCoordinate.latitude, longtitude: touchedAtCoordinate.longitude)
    }
    
    func addPin (latitude: Double, longtitude: Double){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longtitude = longtitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
        pins.append(pin)
        let annotation = PinAnnotation(pin)
        mapView.addAnnotation(annotation)
    }
    
    func deletePin (annotation : MKPointAnnotation){
        let pin = (annotation as! PinAnnotation).pin
        // remove pin from memory array
        let pinIndex = pins.index(of: pin!)!
        pins.remove(at: pinIndex)
        // remove annotation from the map
        mapView.removeAnnotation(annotation)
        // remove pin from persistence store
        dataController.viewContext.delete(pin!)
        try? dataController.viewContext.save()
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
        if editOn {
            self.deletePin(annotation: view.annotation as! MKPointAnnotation)
        } else {
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumView
            mapVC.annotation = view.annotation
            mapVC.dataController = dataController
            mapVC.pin = (view.annotation as! PinAnnotation).pin
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
    }
}

