//
//  DestinationError.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/25/19.
//

import Foundation

struct DestinationError: Codable {
    
    var message: String
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case message = "error_message"
        case status
    }
}
