//
//  GoogleDataProvider.swift
//  Here
//
//  Created by cristina todoran on 07/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GoogleDataProvider{
    
    
    
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GooglePlace]) -> Void)) -> ()
    {
        var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
            task.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            if let aData = data {
                let json = JSON(data:aData, options:JSONSerialization.ReadingOptions.mutableContainers, error:nil)
                if let results = json["results"].arrayObject as? [[String : AnyObject]] {
                    for rawPlace in results {
                        let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
                        placesArray.append(place)
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference) { image in
                                place.photo = image
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(placesArray)
            }
        })
        placesTask?.resume()
    }
    
    
    func fetchPhotoFromReference(_ reference: String, completion: @escaping ((UIImage?) -> Void)) -> () {
        if let photo = photoCache[reference] as UIImage? {
            completion(photo)
        } else {
            let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            session.downloadTask(with: URL(string: urlString)!, completionHandler: {url, response, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let url = url {
                    let downloadedPhoto = UIImage(data: try! Data(contentsOf: url))
                    self.photoCache[reference] = downloadedPhoto
                    DispatchQueue.main.async {
                        completion(downloadedPhoto)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }) .resume()
        }
    }
}
