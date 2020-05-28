//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 18/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let persistenceController = PersistenceController(modelName:"VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        persistenceController.load()
        
        let navVC = window?.rootViewController as! UINavigationController
        let mapVC = navVC.topViewController as! VTMapViewController
        mapVC.persistenceController = persistenceController
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

