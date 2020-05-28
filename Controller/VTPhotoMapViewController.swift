//
//  VTPhotoMapViewController.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 18/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class VTPhotoMapViewController: UIViewController, MKMapViewDelegate
{
    
    @IBOutlet weak var vTMapView: MKMapView!
    @IBOutlet weak var vTCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Image]!
    var vtPin: VTPin!
    var persistenceController: PersistenceController!

    @IBAction func newCollectionBtnPressed(_ sender: Any) {
        vtPin.images = nil
        print(persistenceController.viewContext.hasChanges)
        try? self.persistenceController.viewContext.save()
        vTCollectionView.reloadData()
        photos.removeAll()
        getFlickrImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let predicate = NSPredicate(format: "vtPin == %@", vtPin)
        // fetch request
        let fetchRequest:NSFetchRequest<Image> = Image.fetchRequest()
        fetchRequest.predicate = predicate
        if let result = try? persistenceController.viewContext.fetch(fetchRequest){
            photos = result
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        vTMapView.addAnnotation(annotation)
       
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let mapRegion = MKCoordinateRegion(center: coordinate, span: mapSpan)
        self.vTMapView.setRegion(mapRegion, animated: true)
        
        if photos.isEmpty {
            getFlickrImages()
        }
        
    }
    
    
     func getFlickrImages(){
         setUIEnabled(false)
         let _ = FlickrInterface.sharedInstance().displayImageFromFlickrBySearch(coordinate) { (photosArray, error) in
             if let error = error {
                 let controller = UIAlertController(title: "", message: "\(error.localizedDescription)", preferredStyle: .alert)
                 
                 controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                 
                 self.present(controller, animated: true, completion: nil)
                 self.setUIEnabled(true)
             }
             for img in photosArray {
                 guard let imageUrlString = img[FlickrInterface.FlickrResponseKeys.MediumURL] as? String else {
                     debugPrint("Cannot find key '\(FlickrInterface.FlickrResponseKeys.MediumURL)' in \(img)")
                     self.setUIEnabled(true)
                     return
                 }
                 
                 // if an image exists at the url, set the image
                 let imageURL = URL(string: imageUrlString)
                 
                guard let imageData = try? Data(contentsOf: imageURL!) else {
                    print("Image does not exist at \(String(describing: imageURL))")
                    self.setUIEnabled(true)
                    return
                }
                 
                 let photo: Image = Image(context: self.persistenceController.viewContext)
                 photo.uniformResourceId = imageURL
                 photo.rawImage = imageData
                 photo.vtPin = self.vtPin
                 try? self.persistenceController.viewContext.save()
                 self.photos.append(photo)
                 
                 DispatchQueue.main.async  {
                     self.vTCollectionView.reloadData()
                 }
             }
             print("End")
             self.setUIEnabled(true)
             DispatchQueue.main.async  {
                 self.vTCollectionView.reloadData()
             }
             
         }

     }
    
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
     
     func setUIEnabled(_ enabled: Bool) {
         DispatchQueue.main.async {
             self.newCollectionBtn.isEnabled = enabled
             
             // adjust newCollectionBtn alphas
             if enabled {
                 self.newCollectionBtn.alpha = 1.0
                 self.activityIndicator.alpha = 0.0
                 self.activityIndicator.stopAnimating()
             } else {
                 self.newCollectionBtn.alpha = 0.5
                 self.activityIndicator.alpha = 1.0
                 self.activityIndicator.startAnimating()
             }
         }
     }
}
