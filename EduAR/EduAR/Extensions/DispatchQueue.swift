//
//  DispatchQueue.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/26/19.
//

import Foundation

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: execute)
    }
}
