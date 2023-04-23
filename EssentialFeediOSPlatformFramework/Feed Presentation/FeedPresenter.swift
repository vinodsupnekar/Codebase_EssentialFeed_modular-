//
//  FeedPresenter.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 18/04/23.
//

import Foundation
import EssentialFeed

protocol FeedLoading: class {
    func display(isLoading: Bool)
}
protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    
    typealias Observer<T> = (T)->Void
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    weak var loadingView: FeedLoading?

    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeedView() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.feedView?.display(feed: feed)
            }
            self.loadingView?.display(isLoading: false )
        }
    }
}
