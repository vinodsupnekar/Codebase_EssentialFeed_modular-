//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL ,bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore",url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedObject = ManagedCache(context: context)
                managedObject.timestamp = timeStamp
                managedObject.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
    public func retrieve(_ completion: @escaping RetrievalCompletion) {
        
        perform { context in
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(.found(
                                            feed: cache.localFeed,
                                            timestamp: cache.timestamp)))
                } else {
                    completion(.success(.emtpy))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
            let context = self.context
            context.perform { action(context) }
        }
}


