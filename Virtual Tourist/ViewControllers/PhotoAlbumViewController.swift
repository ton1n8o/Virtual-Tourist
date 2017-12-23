//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/22/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    
    var pin: Pin?
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        
        print("\(#function) lat: \(pin.latitude!), lon: \(pin.longitude!)")
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        print("\(#function) lat: \(lat), lon: \(lon)\n\n")
        
        Client.shared().searchBy(latitude: lat, longitude: lon)
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
