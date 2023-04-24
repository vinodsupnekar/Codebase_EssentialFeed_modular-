//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 10/04/23.
//

import UIKit
import EssentialFeediOSPlatformFramework

extension FeedViewController {
    func simulateFeedImageNearVisible(at row: Int) {
        let delegate = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int){
        simulateFeedImageNearVisible(at: row)
        
        let delegate = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageNotVisible(at row: Int) -> FeedImageCell?{
        let view = simulateFeedImageVisible(at: row)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        
        return view
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        let cell = dataSource?.tableView(self.tableView, cellForRowAt: index)
        cell?.startShimmering()
        return cell
    }
    
    private var feedImageSection: Int {
        return 0
    }
}
