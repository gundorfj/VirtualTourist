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

class VTMapViewController: UIViewController, MKMapViewDelegate
{
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
}
