//
//  RestaurantData.swift
//  RestaurantSelector
//
//  Created by Alexandre Oliveira on 10/5/18.
//  Copyright © 2018 Alexandre Oliveira. All rights reserved.
//

import Foundation

import Foundation
import SwiftyJSON
import CoreLocation
import MapKit
class RestaurantData {
    
    var yelpJSON : JSON = ""
    var chosenRestaurant : String = ""
    var chosenPlaceLatitude : CLLocationDegrees = 0
    var chosenPlaceLongitude : CLLocationDegrees = 0
    var coordinates = CLLocationCoordinate2D()
    var placeMark = MKPointAnnotation()
}
