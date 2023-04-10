//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 10/04/23.
//

import UIKit
import EssentialFeediOSPlatformFramework

extension FeedImageCell {

    func simulateRetryAction() {
        feedImageViewRetryButton.simulateTap()
    }
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowRetryAction: Bool {
        return !feedImageViewRetryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data?{
        return feedImageView.image?.pngData()
    }
    
}
