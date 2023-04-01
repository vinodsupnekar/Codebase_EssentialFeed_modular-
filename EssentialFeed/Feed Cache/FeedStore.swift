//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Rjvi on 11/03/23.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void

    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread ,if needed.
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread ,if needed.
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread ,if needed.
    func retrieve(_ completion: @escaping RetrievalCompletion )
}

