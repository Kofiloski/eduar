//
//  EventTrigger.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 8/24/19.
//

import Foundation
import CoreLocation

struct EventTrigger {
    var isLocationTriggered: Bool
    var longitude: Double
    var latitude: Double
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var title: String
    var contentIsImage: Bool
    var contentIsAR: Bool
    var content: String
}

extension EventTrigger: Codable {
    init(json: [String: Any]) throws {
        guard let locationTriggered = json["locationTriggered"] as? Bool else {
            throw SerializationError.missing("locationTriggered")
        }
        
        if locationTriggered {
            guard let longitude = json["longitude"] as? Double else {
                throw SerializationError.missing("longitude")
            }
            
            guard let latitude = json["latitude"] as? Double else {
                throw SerializationError.missing("latitude")
            }
            
            let coordinate = (longitude, latitude)
            guard case (-90...90, -180...180) = coordinate else {
                throw SerializationError.invalid("coordinates", coordinate)
            }
            
            self.latitude = latitude
            self.longitude = longitude
        } else {
            self.latitude = 0
            self.longitude = 0
        }
        
        guard let title = json["title"] as? String else {
            throw SerializationError.missing("title")
        }
        
        guard let imageContent = json["imageContent"] as? Bool else {
            throw SerializationError.missing("imageContent")
        }
        
        guard let arContent = json["arContent"] as? Bool else {
            throw SerializationError.missing("arContent")
        }
        
        guard let content = json["content"] as? String else {
            throw SerializationError.missing("content")
        }
        
        self.isLocationTriggered = locationTriggered
        self.title = title
        contentIsImage = imageContent
        contentIsAR = arContent
        self.content = content
    }
}
