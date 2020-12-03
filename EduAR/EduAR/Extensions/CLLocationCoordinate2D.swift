//
//  CLLocationCoordinate2D.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/25/19.
//

import CoreLocation

extension CLLocationCoordinate2D {
    var description: String {
        "\(latitude.description), \(longitude.description)"
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
