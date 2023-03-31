//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

private extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStore(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let managedObjectModel = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }

        let description = NSPersistentStoreDescription(url: url)
        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        persistentContainer.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
        return persistentContainer
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL ,bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore",url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        
        let context = self.context
        context.perform {
            do {
                let managedObject = ManagedCache(context: context)
                managedObject.timestamp = timeStamp
                
                let imageFeed = feed.map { (item) -> ManagedFeedImage in
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.location = item.location
                    managedFeedImage.imageDescription = item.description
                    managedFeedImage.id = item.id
                    managedFeedImage.url = item.url
                    return managedFeedImage
                }
                managedObject.feed = NSOrderedSet(array:imageFeed)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
    public func retrieve(_ completion: @escaping RetrievalCompletion) {        
        let context = self.context
        context.perform {
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            do {
                if let cache = try context.fetch(request).first {
                    completion(.found(
                                (feed: cache.feed.compactMap { ($0 as? ManagedFeedImage)}
                                        .map {
                                                LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)},
                                       timestamp: cache.timestamp)))
                } else {
                    completion(.emtpy)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}


