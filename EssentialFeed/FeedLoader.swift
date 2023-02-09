//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rjvi on 09/02/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
