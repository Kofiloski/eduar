//
//  SerializationError.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 1/21/20.
//

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}
