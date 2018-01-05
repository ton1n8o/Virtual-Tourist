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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout?
    
    // MARK: - Variables
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var pin: Pin?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFlowLayout(self.view.frame.size)
        updateFlowLayout(view.frame.size)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        setupFetchedResultControllerWith(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            // pin selected has no photos
            fetchPhotosFromAPI(pin)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        
    }
    
    // MARK: - Helpers
    
    private func setupFetchedResultControllerWith(_ pin: Pin) {
        
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let pred = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fr.predicate = pred
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    private func fetchPhotosFromAPI(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        Client.shared().searchBy(latitude: lat, longitude: lon) { (photosParsed, error) in
            if let photosParsed = photosParsed {
                print("\(#function) Downloading \(photosParsed.photos.photo.count) photos.")
                self.storePhotos(photosParsed.photos.photo, forPin: pin)
            } else if let error = error {
                print("\(#function) error:\(error)")
                self.showInfo(withTitle: "Error", withMessage: "Error while fetching Photos: \(error)")
            }
        }
    }
    
    private func storePhotos(_ photos: [PhotoParser], forPin: Pin) {
        
        func showErrorMessage(msg: String) {
            self.showInfo(withTitle: "Error", withMessage: msg)
        }
        
        let errorMessage = " image(s) could not be downloaded."
        var errorCount = 0
        
        for (idx, photo) in photos.enumerated() {
            
            Client.shared().downloadImage(imageUrl: photo.url) { (data, error) in
                
                if let data = data {
                    print("\(#function) Downloading \(idx)")
                    self.performUIUpdatesOnMain {
                        _ = Photo(title: photo.title, photoData: data, forPin: forPin, context: self.coreDataStack.context)
                        self.save()
                    }
                } else if let _ = error {
                    errorCount += 1
                }
                
                if idx == photos.count - 1 {
                    print("\(#function) DONE")
                    if errorCount > 0 {
                        let message = "\(errorCount) " + errorMessage
                        showErrorMessage(msg: message)
                    }
                }
                
            }
            
        }
    }
    
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
    
    private func updateFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 5 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
}

// MARK: - UICollectionView DataSource & Delegate

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.identifier, for: indexPath) as! PhotoViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.image = UIImage(data: Data(referencing: photo.image!))
        return cell
    }
}

// MARK: - MKMapViewDelegate

extension PhotoAlbumViewController {
    
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
