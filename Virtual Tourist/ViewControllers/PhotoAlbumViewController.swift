//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/22/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    
    var pin: Pin?
    var ctx: NSManagedObjectContext?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        ctx = coreDataStack.context
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        if let photos = loadPhotos(using: pin), !photos.isEmpty {
            print("\(#function) photos \(photos.count)")
        } else {
            print("\(#function) no photos")
            // pin selected has no photos
            
            func showErrorMessage(msg: String) {
                self.showInfo(withTitle: "Error", withMessage: msg)
            }
            
            Client.shared().searchBy(latitude: lat, longitude: lon) { (photosParsed, error) in
                if let photosParsed = photosParsed {
                    
                    print("\(#function) Downloading \(photosParsed.photos.photo.count) photos.")
                    
                    let errorMessage = " image(s) could not be downloaded."
                    var errorCount = 0
                    
                    for (idx, photo) in photosParsed.photos.photo.enumerated() {
                        
                        Client.shared().downloadImage(imageUrl: photo.url) { (data, error) in
                            
                            if let data = data {
                                
                                print("\(#function) Downloading \(idx)")
                                
                                self.performUIUpdatesOnMain {
                                    let photoCD = Photo(photoData: data, forPin: pin, context: self.ctx!)
                                    photoCD.pin = pin
                                }
                                
                            } else if let _ = error {
                                errorCount += 1
                            }
                            
                            if idx == photosParsed.photos.photo.count - 1 {
                                
                                print("\(#function) DONE")
                                
                                self.performUIUpdatesOnMain {
                                    self.save()
                                }
                                
                                if errorCount > 0 {
                                    let message = "\(errorCount) " + errorMessage
                                    showErrorMessage(msg: message)
                                }
                            }
                            
                        }
                        
                    }
                    
                } else if let error = error {
                    print("\(#function) error:\(error)")
                    self.showInfo(withTitle: "Error", withMessage: "Error while fetching Photos: \(error)")
                }
            }
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        
    }
    
    // MARK: - Helpers
    
    private func showOnTheMap(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
    private func loadPhotos(using pin: Pin) -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        var photos: [Photo]?
        do {
            try photos = coreDataStack.fetchPhotos(predicate, entityName: Photo.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while lading Photos from disk: \(error)")
        }
        return photos
    }
    
}

extension PhotoAlbumViewController {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
