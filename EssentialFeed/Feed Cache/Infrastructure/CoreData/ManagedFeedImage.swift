//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

@objc(ManagedFeedImage)
 class ManagedFeedImage: NSManagedObject {
    @NSManaged  var id: UUID
    @NSManaged  var imageDescription: String?
    @NSManaged  var location: String?
    @NSManaged  var url: URL
    @NSManaged  var cache: ManagedCache
    
     var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
        }
}

extension ManagedFeedImage {
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
