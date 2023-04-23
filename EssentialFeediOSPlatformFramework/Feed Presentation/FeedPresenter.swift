//
//  FeedPresenter.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 18/04/23.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    
    typealias Observer<T> = (T)->Void
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeedView() {
        loadingView?.display( FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.feedView?.display(FeedViewModel(feed:feed))
            }
            self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
