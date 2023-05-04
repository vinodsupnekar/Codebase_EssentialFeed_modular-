//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Rjvi on 03/05/23.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }

        func cancel() {
            preventingFurtherCompletion()
            wrapped?.cancel()
        }
        
        private func preventingFurtherCompletion() {
            completion = nil
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
                
                task.complete(with: result
                                .mapError{ _ in Error.connectivity }
                                .flatMap { (data, response) in
                                    let isValidResponse = response.isOK && !data.isEmpty
                                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                                })
        }
        return task
    }
}
