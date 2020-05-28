//
//  FlickrInterface.swift
//  VirtualTourist
//
//  Created by Jan Gundorf on 26/05/2020.
//  Copyright © 2020 Jan Gundorf. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class FlickrInterface: NSObject {

    // MARK: Shared Instance
    class func sharedInstance() -> FlickrInterface {
        struct Singleton {
            static var sharedInstance = FlickrInterface()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Flickr Constants
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
        
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "f44caaf5963ae7c26201b8828c675d63"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPageValue = "26"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Page = "page"
        static let PerPage = "per_page"

    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
        static let Pages = "pages"
    }
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    

    func displayImageFromFlickrBySearch(_ coordinate: CLLocationCoordinate2D, completionhandler: @escaping (_ result: [[String:Any]], _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var methodParameters = getFlickerParams(coord: coordinate)
        
        let session = URLSession.shared
        let request = URLRequest(url: createURLForRequest(methodParameters))
        
        let task = session.dataTask(with: request) { (info, response, error) in
            
            func alertMe(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionhandler([[:]], NSError(domain: "displayImageFromFlickrBySearch", code: 1, userInfo: userInfo as [String : Any]))
            }
            
            // Guards
            // ********
            guard (error == nil) else {
                alertMe("Error happened in request: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let info = info else {
                alertMe("No info in reposne")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            guard  httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                alertMe("Status code from response: '\(httpResponse.statusCode)'")
                return
            }

            
            let result: [String:AnyObject]!
            do {
                result = try JSONSerialization.jsonObject(with: info, options: .allowFragments) as? [String:AnyObject]
            } catch {
                alertMe("ParseError: '\(info)'")
                return
            }
            
            guard let stat = result[FlickrInterface.FlickrResponseKeys.Status] as? String, stat == FlickrInterface.FlickrResponseValues.OKStatus else {
                alertMe("Flickr error : \(String(describing: result))")
                return
            }

            guard let imageDir = result[FlickrInterface.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                alertMe("No key '\(FlickrInterface.FlickrResponseKeys.Photos)' in \(String(describing: result))")
                return
            }
            
            
            guard let totalPages = imageDir[FlickrInterface.FlickrResponseKeys.Pages] as? Int else {
                alertMe("No key  '\(FlickrInterface.FlickrResponseKeys.Pages)' in \(imageDir)")
                return
            }
            
            let limitTotal = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(limitTotal))) + 1
            let _ = self.displayPhotosFRomSearch(methodParameters, withPageNumber: randomPage, completionHandlerForGET: { (results, error) in
                completionhandler(results, error)
            })
        }
        
        task.resume()
        return task
    }
    
    private func displayPhotosFRomSearch(_ methodParams: [String: AnyObject], withPageNumber: Int, completionHandlerForGET: @escaping (_ result: [[String:Any]], _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var methodParamsWithPageNumber = methodParams

        methodParamsWithPageNumber[FlickrInterface.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        let request = URLRequest(url: createURLForRequest(methodParams))
        let task = URLSession.shared.dataTask(with: request) { (info, response, error) in
            
            func alertMe(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET([[:]], NSError(domain: "displayImageFromFlickrBySearchWithPageNumber", code: 1, userInfo: userInfo as [String : Any]))
            }
            
            // Guards
            // ********
            guard (error == nil) else {
                alertMe("Error happened in request: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let info = info else {
                alertMe("No info in reposne")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            guard  httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                alertMe("Status code from response: '\(httpResponse.statusCode)'")
                return
            }
            
            let result: [String:AnyObject]!
            do {
                result = try JSONSerialization.jsonObject(with: info, options: .allowFragments) as? [String:AnyObject]
            } catch {
                alertMe("ParseError: '\(info)'")
                return
            }
            
            guard let stat = result[FlickrInterface.FlickrResponseKeys.Status] as? String, stat == FlickrInterface.FlickrResponseValues.OKStatus else {
                alertMe("Flickr error : \(String(describing: result))")
                return
            }
            
            guard let imageDir = result[FlickrInterface.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                alertMe("No key '\(FlickrInterface.FlickrResponseKeys.Photos)' in \(String(describing: result))")
                return
            }
            
            guard let imageList = imageDir[FlickrInterface.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                alertMe("No key '\(FlickrInterface.FlickrResponseKeys.Photo)' in \(imageDir)")
                return
            }
            
            completionHandlerForGET(imageList, nil)
            
        }
        task.resume()
        return task
    }
    
    
    
    private func getFlickerParams(coord: CLLocationCoordinate2D) -> [String:AnyObject]  {
        
        let flickrparameter = [
            FlickrInterface.FlickrParameterKeys.Method: FlickrInterface.FlickrParameterValues.SearchMethod,
            FlickrInterface.FlickrParameterKeys.APIKey: FlickrInterface.FlickrParameterValues.APIKey,
            FlickrInterface.FlickrParameterKeys.SafeSearch: FlickrInterface.FlickrParameterValues.UseSafeSearch,
            FlickrInterface.FlickrParameterKeys.Extras: FlickrInterface.FlickrParameterValues.MediumURL,
            FlickrInterface.FlickrParameterKeys.Format: FlickrInterface.FlickrParameterValues.ResponseFormat,
            FlickrInterface.FlickrParameterKeys.PerPage: FlickrInterface.FlickrParameterValues.PerPageValue,
            FlickrInterface.FlickrParameterKeys.NoJSONCallback: FlickrInterface.FlickrParameterValues.DisableJSONCallback,
            FlickrInterface.FlickrParameterKeys.Lat: coord.latitude,
            FlickrInterface.FlickrParameterKeys.Lon: coord.longitude
            ] as [String:AnyObject]
        return flickrparameter
    }
    
    
    private func createURLForRequest(_ parameters: [String:AnyObject]) -> URL {
        
        var uRL_components = URLComponents()
        uRL_components.scheme = FlickrInterface.Constants.APIScheme
        uRL_components.host = FlickrInterface.Constants.APIHost
        uRL_components.path = FlickrInterface.Constants.APIPath
        uRL_components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            uRL_components.queryItems!.append(queryItem)
        }
        return uRL_components.url!
    }
    
}
