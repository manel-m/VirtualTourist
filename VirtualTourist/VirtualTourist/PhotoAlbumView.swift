//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Manel matougui on 9/6/18.
//  Copyright © 2018 udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class PhotoAlbumView: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var annotation : MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Setting Region
        let center = CLLocationCoordinate2D(latitude: (annotation?.coordinate.latitude)!, longitude: (annotation?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        //Adding Pin
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake((annotation?.coordinate.latitude)!, (annotation?.coordinate.longitude)!)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        //objectAnnotation.title = "My Location"
        self.mapView.addAnnotation(objectAnnotation)
    }
    
}
