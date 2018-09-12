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
class PhotoAlbumView: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    
    
    var annotation : MKAnnotation?
    var imageData : [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call API
        searchByLatLon()
       
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
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = annotation?.coordinate.latitude, let longitude = annotation?.coordinate.longitude {
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    func searchByLatLon () {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        displayImageFromFlickrBySearch(methodParameters as [String:AnyObject])
    }
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    // TO DO
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            //print(photosDictionary)
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
 
            }
  
           
            for photo in photosArray {
                let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String
                let imageUrl = URL(string: imageUrlString!)
                if let imageData = try? Data(contentsOf: imageUrl!) {
                    self.imageData.append(imageData)
                }
                
                }
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
//            // if an image exists at the url, set the image and title
//            let imageURL = URL(string: imageUrlString)
//            if let imageData = try? Data(contentsOf: imageURL!) {
//                //array[i]=imageData
//                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.photoImageView.image = UIImage(data: imageData)
//                    self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                }
//            } else {
//                displayError("Image does not exist at \(imageURL)")
//            }
            
            
            }
        // start the task!
        task.resume()
        
    }
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        //print(components.url)
        return components.url!
    }
    
    // collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("imageData.count = \(self.imageData.count)")
        return self.imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        let image = self.imageData[(indexPath as NSIndexPath).row]
        // Set the image
        cell.photoImageView?.image = UIImage(data: image)
        
        // Set the name and image
        //cell.nameLabel.text = villain.name
        //cell.villainImageView?.image = UIImage(named: villain.imageName)
        //cell.schemeLabel.text = "Scheme: \(villain.evilScheme)"
        
        return cell
    }
}
