//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Rjvi on 11/03/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}
