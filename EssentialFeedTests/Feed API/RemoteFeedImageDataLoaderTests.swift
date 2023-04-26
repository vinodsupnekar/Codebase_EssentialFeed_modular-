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
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private class HTTPClienSpy {
        let requestedURLs = [String]()
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (HTTPClienSpy, RemoteFeedImageDataLoader) {
        let client = HTTPClienSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (client, sut)
    }
}
