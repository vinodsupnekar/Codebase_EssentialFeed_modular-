//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 17/03/23.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
  return (items, localItems)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date{
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        return self + TimeInterval(seconds)
    }
}
