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

            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
 //           annotation.title = "title"
            vTmapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = .blue

        return pinView
    }
    
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
