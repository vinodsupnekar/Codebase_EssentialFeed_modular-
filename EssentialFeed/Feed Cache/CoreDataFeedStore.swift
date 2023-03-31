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
        
    }
    
    public func retrieve(_ completion: @escaping RetrievalCompletion) {
        completion(.emtpy)
    }
}


private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var cache: ManagedCache
}


