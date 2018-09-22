//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Manel matougui on 9/21/18.
//  Copyright © 2018 udacity. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation:MKPointAnnotation {
    let pin:Pin!
    
    init(_ pin:Pin) {
        self.pin = pin;
        super.init()
        self.coordinate.latitude = pin.latitude;
        self.coordinate.longitude = pin.longtitude;
    }
}
