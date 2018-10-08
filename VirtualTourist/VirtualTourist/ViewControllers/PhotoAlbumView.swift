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
import CoreData
class PhotoAlbumView: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flawLayout: UICollectionViewFlowLayout!
    
    var annotation : MKAnnotation?
    var dataController:DataController!
    var pin : Pin!
    var photos:[Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        
       self.flowLayout()
        
        // fetch request for Photo
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let results = try? dataController.viewContext.fetch(fetchRequest){
           self.photos = results
        }
    
        if self.photos.count == 0 {
            self.getFromFlicker()
        }
    }
    // flowLayout
    func flowLayout () {
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flawLayout.minimumInteritemSpacing = space
        flawLayout.minimumLineSpacing = space
        flawLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func getFromFlicker() {
        // Call API
        searchByLatLon(latitude: (annotation?.coordinate.latitude)!, longitude: (annotation?.coordinate.longitude)!) { (results) in
            for image in results {
                let photo = Photo(context: self.dataController.viewContext)
                photo.creationDate = Date()
                photo.photoData = image
                photo.pin = self.pin
                try? self.dataController.viewContext.save()
                self.photos.append(photo)
            }
            
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
        }
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
    // collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        let image = self.photos[(indexPath as NSIndexPath).row].photoData!
        // Set the image
        cell.photoImageView?.image = UIImage(data: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delete image from in-memory array
        let photo = photos[indexPath.row]
        photos.remove(at: indexPath.row)
        // delete image from persistent store
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()

        self.collectionView.reloadData()
    }
    
    @IBAction func newCollection(_ sender: Any) {
        for photo in photos {
            dataController.viewContext.delete(photo)
        }
        try? dataController.viewContext.save()
        photos.removeAll()
        getFromFlicker()
        
    }
}
