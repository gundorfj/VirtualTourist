//
//  VTCollectionView+VTPhotoMapViewController.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 26/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import Foundation
import UIKit


extension VTPhotoMapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let vtCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VTImageCell", for: indexPath) as! VTImageCollectionCell
        if let rawImage = photos[indexPath.row].rawImage {
            vtCell.VTImage.image = UIImage(data: rawImage)
        }
        return vtCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        persistenceController.viewContext.delete(photos[indexPath.row])
        try? self.persistenceController.viewContext.save()
        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewBounds = collectionView.bounds
        return CGSize(width: (viewBounds.width/2)-4, height: viewBounds.height/2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
