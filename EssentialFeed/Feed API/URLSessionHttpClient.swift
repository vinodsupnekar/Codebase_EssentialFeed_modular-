//
//  URLSessionHttpClient.swift
//  EssentialFeed
//
//  Created by Rjvi on 01/03/23.
//

import Foundation

public final class URLSessionHttpClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValueReprentation: Error {
    }
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }

    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion( Result {
                if let error = error {
                    throw error
                } else if let data = data,
                          let response = response as? HTTPURLResponse {
                     return ((data, response))
                }
                else {
                    throw UnexpectedValueReprentation()
                }
            })
            
        }
        
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
