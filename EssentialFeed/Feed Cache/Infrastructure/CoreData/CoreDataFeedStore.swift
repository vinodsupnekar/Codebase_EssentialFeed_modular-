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
                    completion(.found(
                                (feed: cache.localFeed,
                                       timestamp: cache.timestamp)))
                } else {
                    completion(.emtpy)
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

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
            return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
        }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let imageFeed = localFeed.map { (item) -> ManagedFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.location = item.location
            managedFeedImage.imageDescription = item.description
            managedFeedImage.id = item.id
            managedFeedImage.url = item.url
            
            return managedFeedImage
        }
        return NSOrderedSet(array:imageFeed)
    }

}


