//
//  Location.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/4/19.
//

import Foundation
import CoreLocation

struct Location {
    
    var name: String
    var longitude: Double
    var latitude: Double
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, lng: Double, lat: Double) {
        self.name = name
        longitude = lng
        latitude = lat
    }
}

extension Location: Codable  {
    
    init(JSON: [String: Any]) throws {
        guard let name = JSON["name"] as? String else {
            throw SerializationError.missing("name")
        }

        guard let longitude = JSON["longitude"] as? Double else {
            throw SerializationError.missing("longitude")
        }

        guard let latitude = JSON["latitude"] as? Double else {
            throw SerializationError.missing("latitude")
        }

        let coordinate = (latitude, longitude)
        guard case (-90...90, -180...180) = coordinate else {
            throw SerializationError.invalid("coordinates", coordinate)
        }

        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
