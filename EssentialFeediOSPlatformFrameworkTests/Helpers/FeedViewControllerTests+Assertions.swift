//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 10/04/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOSPlatformFramework

extension FeedUIIntegrationTests {
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard  sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, but got \(sut.numberOfRenderedFeedImageViews()) instead")
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
            
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, but got \(String(describing: view)) instead")
        }
        let shouldLocationVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationVisible, "Expected isShowingLocation to be \(shouldLocationVisible) for image view at index \(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location)
        XCTAssertEqual(cell.locationText, image.location, "Expected location to be \(String(describing: image.location)) for image view at index \(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description to be \(String(describing: image.description)) for image view at index \(index))", file: file, line: line)

    }
}
