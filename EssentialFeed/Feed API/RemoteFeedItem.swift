//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Rjvi on 13/03/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
