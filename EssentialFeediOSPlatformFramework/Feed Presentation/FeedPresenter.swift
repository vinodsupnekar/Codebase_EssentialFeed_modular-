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
        
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return  Bundle(for: FeedPresenter.self).localizedString(forKey: "FEED_VIEW_TITLE", value: nil, table: "Feed")
    }

    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
           return DispatchQueue.main.async { [weak self] in
            self?.didStartLoadingFeed()
            }
        }
        loadingView.display( FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
           return DispatchQueue.main.async { [weak self] in
            self?.didFinishLoadingFeed(with: feed)
            }
        }
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
           return DispatchQueue.main.async { [weak self] in
            self?.didFinishLoadingFeed(with: error)
            }
        }
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
