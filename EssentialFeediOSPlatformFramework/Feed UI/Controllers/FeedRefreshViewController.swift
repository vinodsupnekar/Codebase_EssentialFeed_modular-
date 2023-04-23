//
//  FeedRefreshViewController.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 10/04/23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoading {
   
    
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let viewPresenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.viewPresenter = presenter
    }
    
    @objc func refresh() {
        viewPresenter.loadFeedView()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}
