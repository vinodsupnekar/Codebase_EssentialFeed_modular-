//
//  FeedViewController.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 07/04/23.
//

import UIKit
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

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {

    private var refreshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(feedRefreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = feedRefreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view

        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
        cellController(forRowAt: indexPath).preload()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { index in
            cancelCellControllerLoad(forRowAt: index)
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
    
}
