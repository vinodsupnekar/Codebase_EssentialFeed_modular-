//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Rjvi on 31/03/23.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    @NSManaged internal var id: UUID
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
    @NSManaged internal var cache: ManagedCache
    
    internal var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
        }
}

extension ManagedFeedImage {
    internal static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
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
