//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rjvi on 14/02/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        public static func == (lhs: Result, rhs: Result) -> Bool {
            switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure, .failure):
                return true
            default:
                return false
            }
        }
        
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url:URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { (result) in
            switch result {
                case .success:
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
            break
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
}
