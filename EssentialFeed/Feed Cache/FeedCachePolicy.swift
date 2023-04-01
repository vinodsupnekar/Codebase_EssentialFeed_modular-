//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Rjvi on 25/03/23.
//

import Foundation

 final class FeedCachePolicy {
    private init() { }

    private static let calender = Calendar(identifier: .gregorian)
    
    private static var maxCacheInDays: Int {
        return 7
    }
    
     static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard  let maxCacheAge = calender.date(byAdding: .day,value: maxCacheInDays, to: timestamp) else {return false}
        return date < maxCacheAge
        
    }
}
