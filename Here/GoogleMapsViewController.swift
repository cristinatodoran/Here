//
//  GoogleMapsViewController.swift
//  Here
//
//  Created by cristina todoran on 07/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation


class GoogleMapsViewController : UIViewController{
     
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    let locationManager = CLLocationManager()
    let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 10000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Types Segue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as!  TableViewController
            controller.selectedTypes = searchedTypes
            controller.delegate = self
        }
    }
    /*Creates a GMSGeocoder object to turn a latitude and longitude coordinate into a street address.
     *Asks the geocoder to reverse geocode the coordinate passed to the method. 
     *It then verifies there is an address in the response of type GMSAddress. 
     *This is a model class for addresses returned by the GMSGeocoder.
     *Sets the text of the addressLabel to the address returned by the geocoder.
     *Once the address is set, animate the changes in the label’s intrinsic content size. 
     */
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            self.addressLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                self.addressLabel.text = lines.joined(separator: "\n")
                
                let labelHeight = self.addressLabel.intrinsicContentSize.height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }
    
    /*Clear the map of all markers.
     *Use dataProvider to query Google for nearby places around the searchRadius, filtered to the user’s selected types.
     *Enumerate through the results returned in the completion closure and create a PlaceMarker for each result.
     *Set the marker’s map. This line of code is what tells the map to render the marker.    
     */
    func fetchNearbyPlaces(_ coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            for place: GooglePlace in places {
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: UIBarButtonItem) {
        
        fetchNearbyPlaces(mapView.camera.target)
    }
}

    // MARK: - TypesTableViewControllerDelegate
    extension GoogleMapsViewController :  TableViewControllerDelegate {
        
        func typesController(_ controller: TableViewController, didSelectTypes types: [String]) {
            
            searchedTypes = controller.selectedTypes.sorted()
            dismiss(animated: true, completion: nil)
            fetchNearbyPlaces(mapView.camera.target)
            
        }
}

    // MARK: - CLLocationManagerDelegate
    extension GoogleMapsViewController: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                mapView.isMyLocationEnabled = true
                mapView.settings.myLocationButton = true
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                locationManager.stopUpdatingLocation()
                fetchNearbyPlaces(location.coordinate)
            }
        }
    }

    // MARK: - GMSMapViewDelegate
    extension GoogleMapsViewController: GMSMapViewDelegate {
        func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
            reverseGeocodeCoordinate(position.target)
        }
        
        /*This checks if the movement originated from a user gesture; 
         *if so, it un-hides the location pin using the fadeIn(_:) method.
         *Setting the map’s selectedMarker to nil will remove the currently presented infoView     
         */
        func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
            addressLabel.lock()
            
            if (gesture) {
                mapCenterPinImage.fadeIn(0.25)
                mapView.selectedMarker = nil
            }
        }
        /*First cast the tapped marker to a PlaceMarker.
         *Next you create a MarkerInfoView from its nib.
         *Then you apply the place name to the nameLabel.
         *Check if there’s a photo for the place. If so, add that photo to the info view. If not, add a generic photo instead.
         */
        func mapView(_ mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
            let placeMarker = marker as! PlaceMarker
            
            if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
                infoView.nameLabel.text = placeMarker.place.name
                
                if let photo = placeMarker.place.photo {
                    infoView.placePhoto.image = photo
                } else {
                    infoView.placePhoto.image = UIImage(named: "generic")
                }
                
                return infoView
            } else {
                return nil
            }
        }
        //This method simply hides the location pin when a marker is tapped
        func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
            mapCenterPinImage.fadeOut(0.25)
            return false
        }
        
        func didTapMyLocationButton(for mapView: GMSMapView!) -> Bool {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
            return false
        }
}
