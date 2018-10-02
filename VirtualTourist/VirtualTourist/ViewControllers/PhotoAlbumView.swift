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
class PhotoAlbumView: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flawLayout: UICollectionViewFlowLayout!
    
    var annotation : MKAnnotation?
    var imageData : [Data] = []
    var dataController:DataController!
    var photo: Photo!
    var pin : Pin!
    var photos:[Photo] = []
//    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // flowLayout
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flawLayout.minimumInteritemSpacing = space
        flawLayout.minimumLineSpacing = space
        flawLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // fetch request for Photo
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let results = try? dataController.viewContext.fetch(fetchRequest){
           self.photos = results
        }
    
        print("photos in store \(self.photos.count)")
        if self.photos.count == 0 {
            // Call API
            searchByLatLon(latitude: (annotation?.coordinate.latitude)!, longitude: (annotation?.coordinate.longitude)!) { (results) in
                self.imageData = results
                for image in self.imageData {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.creationDate = Date()
                    photo.photoData = image
                    photo.pin = self.pin
                    try? self.dataController.viewContext.save()
                }
                
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        } else {
            for photo in photos {
                let data = photo.photoData!
                self.imageData.append(data)
            }
            
            self.collectionView.reloadData()
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //fetchedResultsController = nil
    }
    


    // collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("imageData.count = \(self.imageData.count)")
        
        return self.imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        let image = self.imageData[(indexPath as NSIndexPath).row]
        // Set the image
        cell.photoImageView?.image = UIImage(data: image)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
//        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VillainDetailViewController") as! VillainDetailViewController
//        detailController.villain = self.allVillains[(indexPath as NSIndexPath).row]
//        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
}
