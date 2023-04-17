//
//  FeedViewComposer.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 17/04/23.
//

import Foundation
import EssentialFeed

final public class FeedViewComposer {
    
    private init() {}
    
    public static func feedComposerWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(feedRefreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo feedViewController: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
       return { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
        }
    }
    }
 }
