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
import SimpleImageViewer

class MapViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Variables
    var showNoGpsMessage = true
    var images = [Image]()
    var annotationsAdded = [MKAnnotation]()
    var firstTime = true
    
    //MARK: - Constants
    let controller = MapController()
    let regionRadius: CLLocationDistance = 5000 //5000m
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Map and locationsetup
        locationManager.delegate = self
        mapView.delegate = self
        mapView.userTrackingMode = .follow //Follow the user when moving around
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addAnnotations() //Add annotations for each time view appears, to get new images after refresh of public images
    }
    
    //MARK: HelperMethods for Map
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotations(){
        self.images.removeAll()
        self.images = controller.getAllImages()

        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        var counter = 0
        for image in images {
            if image.lat != 0.0 && image.long != 0.0 {
                counter = counter + 1
                mapView.addAnnotation(image);
            }
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let customAnnotationView = annotationView {
            //Remove subviews, if any (to prevent wrong images showing when tapping an annotation)
            for view in customAnnotationView.subviews {
                view.removeFromSuperview()
            }
            //Add imageview as subview to annotation
            let annoImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30, height: 30))
            annoImageView.layer.cornerRadius = annoImageView.layer.frame.size.width / 2
            annoImageView.layer.borderColor = UIColor.red.cgColor
            annoImageView.layer.borderWidth = 5
            annoImageView.layer.masksToBounds = true
            annoImageView.contentMode = .scaleAspectFill
            annoImageView.isUserInteractionEnabled = false
            customAnnotationView.addSubview(annoImageView)
            customAnnotationView.frame = annoImageView.frame

            if let imageAnno = annotation as? Image {
                //Get image from cache
                if let image = SDImageCache.shared().imageFromDiskCache(forKey: imageAnno.imageUrl!) {
                    annoImageView.image = image
                } else {
                    //Get image from web if not cached
                    SDWebImageManager.shared().loadImage(with: URL(string: imageAnno.imageUrl!), options: [], progress: { (int1, int2, url) in
                    }, completed: { (image, data, error, cacheType, bool, url) in
                        annoImageView.image = image
                    })
                }
            }
            
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Center studio on map when selected
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        //Show image in full size when tapping
        if let image = view.annotation as? Image {
            if let imageView = view.subviews.first as? UIImageView {
                let configuration = ImageViewerConfiguration { config in
                    config.imageView = imageView
                }
                present(ImageViewerController(configuration: configuration), animated: true)
                mapView.deselectAnnotation(view.annotation, animated: true)
            }

        }
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
