//
//  VTMapViewController.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 18/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class VTMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate
{

    @IBOutlet weak var vTmapView: MKMapView!
    var vTUserPins: [VTPin] = []
    var persistenceController: PersistenceController!

    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add Gesture Recognizer to map
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        vTmapView.addGestureRecognizer(gestureRecognizer)
        vTmapView.delegate = self
        
        // fetch request
        let fetchRequest:NSFetchRequest<VTPin> = VTPin.fetchRequest()
                
        if let result = try? persistenceController.viewContext.fetch(fetchRequest){
            vTUserPins = result
            vTmapView.removeAnnotations(vTmapView.annotations)
            addAnnotations()
        }
    }
    
    func addAnnotations()
    {
        vTmapView.removeAnnotations(vTmapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in vTUserPins {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // When the array is complete, we add the annotations to the map.
        vTmapView.addAnnotations(annotations)
    }
    
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: vTmapView)
            let coordinate = vTmapView.convert(location,toCoordinateFrom: vTmapView)
            
            let pin = VTPin(context: persistenceController.viewContext)

            pin.latitude = coordinate.latitude.magnitude
            pin.longitude = coordinate.longitude.magnitude
            do {
                try persistenceController.viewContext.save()
            }
            catch{
                print("error")
            }
            vTUserPins.append(pin)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "title"
            vTmapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .blue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the VTPhotoMapViewController
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumVC") as? VTPhotoMapViewController
        controller?.coordinate = view.annotation?.coordinate
        
        for pin in vTUserPins {
            if pin.latitude.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.vtPin = pin
            }
        }
        controller?.persistenceController = persistenceController
        self.show(controller!, sender: nil)
    }
}
