//
//  StoryEvent.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 8/24/19.
//

import Foundation
import CoreLocation

struct StoryEvent {
    
    var finalLocation: Location
    var eventTriggers: [EventTrigger]?
}

extension StoryEvent: Codable {
    
    init(json: [String: Any]) throws {
        guard let finalLocation = json["FinalLocation"] as? Location else {
            throw SerializationError.missing("FinalLocation")
        }
        
        guard let eventTriggers = json["EventTriggers"] as? [EventTrigger] else {
            throw SerializationError.missing("EventTriggers")
        }
        
        self.finalLocation = finalLocation
        self.eventTriggers = eventTriggers
    }
}
