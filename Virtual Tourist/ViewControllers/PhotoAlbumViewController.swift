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
        
        guard let pin = pin else {
            return
        }
        print("\(#function) lat: \(pin.latitude!), lon: \(pin.longitude!)")
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        print("\(#function) lat: \(lat), lon: \(lon)\n\n")
        
        Client.shared().searchBy(latitude: lat, longitude: lon)
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        
    }

}
