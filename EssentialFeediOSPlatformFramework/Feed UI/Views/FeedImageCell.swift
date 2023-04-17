//
//  FeedImageCell.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 07/04/23.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationContainer =  UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageView = UIImageView()
    public let feedImageContainer = UIView()
    public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
