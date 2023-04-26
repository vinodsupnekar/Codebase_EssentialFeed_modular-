//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/04/23.
//

import XCTest

class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let client = HTTPClienSpy()
        _ = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private class HTTPClienSpy {
        let requestedURLs = [String]()
    }

}
