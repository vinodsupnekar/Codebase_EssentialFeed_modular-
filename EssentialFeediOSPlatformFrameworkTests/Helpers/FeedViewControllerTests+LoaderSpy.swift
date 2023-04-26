//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 10/04/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOSPlatformFramework

extension FeedUIIntegrationTests {

    class LoaderSpy: FeedLoader, FeedImageDataLoader{
        
        // MARK:- Feed Loader
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        private(set) var feedRequests: [((FeedLoader.Result) -> Void)] = []
        
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [],at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index:Int) {
            let error = NSError(domain: "", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK:- Image Loader
        private(set) var imageRequests =  [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError( at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}
