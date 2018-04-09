//
//  MapViewController.swift
//  FlickrDemoApp
//
//  Created by Nicolai Harbo on 05/04/2018.
//  Copyright © 2018 nicoware. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class MapViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Variables
    var showNoGpsMessage = true
    var images = [Image]()
    var annotations = [MKAnnotation]()
    
    //MARK: - Constants
    let controller = MapController()
    let regionRadius: CLLocationDistance = 5000 //5000m
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
//    let annotation = CustomPointAnnotation()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Map and locationsetup
        locationManager.delegate = self
        mapView.delegate = self
        mapView.userTrackingMode = .follow //Follow the user when moving around
        self.images = controller.getAllImages()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.addAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addAnnotations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: HelperMethods for Map
    
    func centerMapOnLocation(location: CLLocation) {
        // Decides the startingpoint of zoom
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        // Finds location and zooms
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotations(){
        mapView.removeAnnotations(annotations) //Remove current annotations, if any
        for image in images {
            if image.lat != 0.0 && image.long != 0.0 {
                annotations.append(image)
                mapView.addAnnotation(image);
            }
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Image else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("PIN TAPPED!!")
        // Center studio on map when selected
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //        view.image = [UIImage imageNamed:@"selected_image"];
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Callout tapped!!!")
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue: CLLocationCoordinate2D = manager.location!.coordinate {
            let initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            self.centerMapOnLocation(location: initialLocation)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if showNoGpsMessage {

            let alertController = UIAlertController(title: "Lokalitets tjeneste slået fra", message: "For at kunne finde de bedste studier nær dig, skal du tillade Studios brug af din lokalitet.", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Annuller", style: .cancel) { (UIAlertAction) in
                self.showNoGpsMessage = false
            }

            let settingsAction = UIAlertAction(title: "Indstillinger", style: .default) { (UIAlertAction) in
                self.showNoGpsMessage = false
                self.navigationController?.popViewController(animated: true)
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
