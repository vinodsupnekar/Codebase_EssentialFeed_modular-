//
//  CoredataHelpers.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

internal extension NSPersistentContainer {
    
    internal enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStore(Swift.Error)
    }
    
    internal static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
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

internal extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
