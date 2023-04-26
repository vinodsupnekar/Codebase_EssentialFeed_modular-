//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/04/23.
//

import XCTest
import EssentialFeed

protocol HTTPImageClient {
    func loadImageData(url: URL)
}

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(url: URL) {
        client.get(from: url) { _ in }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_requests_dataFromURL() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(url: url)

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    private class HTTPClienSpy: HTTPClient {

        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)

        }
        
    }

    // MARK:- Helper's
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (HTTPClienSpy, RemoteFeedImageDataLoader) {
        let client = HTTPClienSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (client, sut)
    }
}
