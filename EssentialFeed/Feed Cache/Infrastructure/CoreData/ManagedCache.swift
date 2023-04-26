//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

@objc(ManagedCache)
 class ManagedCache: NSManagedObject {
    @NSManaged  var timestamp: Date
    @NSManaged  var feed: NSOrderedSet
    
     var localFeed: [LocalFeedImage] {
            return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
 
extension ManagedCache {
     static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}
