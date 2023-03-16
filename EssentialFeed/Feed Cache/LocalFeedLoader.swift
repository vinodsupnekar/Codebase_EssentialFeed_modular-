//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Rjvi on 11/03/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate: () -> Date
    private let calender = Calendar(identifier: .gregorian)

    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.deleteCacheFeed {[weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed: feed, timetamp) where self.validate(timetamp):
                completion(.success(feed.toModels()))
            case .found:
                self.store.deleteCacheFeed { _ in }
                completion(.success([]))
            case.emtpy:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { _ in }
        store.deleteCacheFeed { _ in }
    }
    
    private var maxCacheInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard  let maxCacheAge = calender.date(byAdding: .day,value: maxCacheInDays, to: timestamp) else {return false}
        return currentDate() < maxCacheAge
        
    }
    
    private func cache(_ feed: [FeedImage], with completion : @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timeStamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
            
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}



