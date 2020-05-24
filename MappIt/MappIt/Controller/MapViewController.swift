// Nelly Shieh
// nichunsh@usc.edu
//
//  ViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotations = [MKAnnotation]()
    var events = [Event]()
    var annotate = MapAnnotationModel()
    
    private let savedEvents = EventsModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerMapAnnotationViews()
        mapView.delegate = self
        
        // loads annotations
        activityIndicator.startAnimating()
        events = savedEvents.getMapEvents()
        
        // runs openWeather API for the small list of events
        annotate.loadEvents(events: events) { (success) in
            
            self.annotations = success
            self.mapView.addAnnotations(self.annotations)
            self.activityIndicator.stopAnimating()
            
            // get the most recent event's coordinat else a random from no date events
            if let center = self.annotate.getMostRecentCoordinates() {
                let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                self.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
            }
            
        }
        
    }
    
    // reloads annotation if it is different
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let e = savedEvents.getMapEvents()
        
        if e != events{
            activityIndicator.startAnimating()
            mapView.removeAnnotations(annotations)
            events = e
            annotate.loadEvents(events: events) { (success) in
                
                self.annotations = success
                self.mapView.addAnnotations(self.annotations)
                self.activityIndicator.stopAnimating()
                if let center = self.annotate.getMostRecentCoordinates() {
                    let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                    self.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
                }
                
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // registers reuseable markers
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(Annotation.self))
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(DatelessAnnotation.self))
    }
    
    
}

// mapview delegation
extension MapViewController: MKMapViewDelegate {
    
    // impement the setup of the annotation markers
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? Annotation {
            annotationView = setupAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? DatelessAnnotation {
            annotationView = setupDatelessAnnotationView(for: annotation, on: mapView)
        }
        
        return annotationView
    }
    
    // set up for annotations with dates
    private func setupAnnotationView(for annotation: Annotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(Annotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.markerTintColor = UIColor.red
        }
        
        return view
    }
    
    // set up for annotations without dates
    private func setupDatelessAnnotationView(for annotation: DatelessAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(DatelessAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.markerTintColor = UIColor.purple
            
        }
        
        return view
    }
}

