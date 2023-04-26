//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Rjvi on 13/03/23.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
