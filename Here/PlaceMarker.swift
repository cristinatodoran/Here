//
//  PlaceMarker.swift
//  Here
//
//  Created by cristina todoran on 08/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import UIKit

import UIKit

class PlaceMarker: GMSMarker {
    let place: GooglePlace
    
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
