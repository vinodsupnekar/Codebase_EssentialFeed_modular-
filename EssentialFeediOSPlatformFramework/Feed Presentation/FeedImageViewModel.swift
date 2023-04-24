//
//  FeedImageViewModel.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 17/04/23.
//

import Foundation
//import UIKit
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
