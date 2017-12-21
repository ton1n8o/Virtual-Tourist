//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/6/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Variables
    
    var pinTapped: Pin?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            let location = sender.location(in: mapView)
            let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
            
            print("addPinGesture: Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
        
            _ = Pin(
                latitude: String(locCoord.latitude),
                longitude: String(locCoord.longitude),
                context: coreDataStack.context
            )
            save()
            
            // Client.shared().searchBy(latitude: locCoord.latitude, longitude: locCoord.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locCoord
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Helpers
    
    private func save() {
        do {
            try coreDataStack.saveContext()
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while saving Pin location: \(error)")
        }
    }
    
    private func loadPin(latitude: String, longitude: String) {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pins: [Pin]!
        do {
            try pins = coreDataStack.fetchPin(predicate, entityName: Pin.name)
        } catch {
            print("error:\(error)")
        }
        print(pins)
    }
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showInfo(withMessage: "No link defined.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        mapView.deselectAnnotation(annotation, animated: true)
        print("pin selected: lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        loadPin(
            latitude: String(annotation.coordinate.latitude),
            longitude: String(annotation.coordinate.longitude)
        )
    }

}
