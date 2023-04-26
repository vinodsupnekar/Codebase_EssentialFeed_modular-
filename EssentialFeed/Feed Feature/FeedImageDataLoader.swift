//
//  FeedImageDataLoader.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 10/04/23.
//
    
import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping(Result) -> Void) -> FeedImageDataLoaderTask
}
