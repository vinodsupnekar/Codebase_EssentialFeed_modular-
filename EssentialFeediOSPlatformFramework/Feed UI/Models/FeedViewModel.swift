//
//  FeedViewModel.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 12/04/23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad:(([FeedImage]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
            }
            self.isLoading = false
        }
    }
}
