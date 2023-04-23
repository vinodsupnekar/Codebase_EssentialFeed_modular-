//
//  FeedViewComposer.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 17/04/23.
//

import UIKit
import EssentialFeed

final public class FeedViewComposer {
    
    private init() {}
    
    public static func feedComposerWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedViewController = FeedViewController(feedRefreshController: refreshController)
        presenter.loadingView = refreshController
        presenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    
 }

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTranfrormer: UIImage.init))
    }
    }
}
