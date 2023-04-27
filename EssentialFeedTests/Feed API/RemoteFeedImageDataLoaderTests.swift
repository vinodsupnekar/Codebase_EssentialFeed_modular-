//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/04/23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case .success: completion(.failure(anyNSError()))
            case let .failure(error): completion(.failure(error))
            }
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(url: url)

        XCTAssertEqual(client.receivedMessages.first?.url, url)
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(url: url)
        sut.loadImageData(url: url)

        let urlArray = client.receivedMessages.map { $0.url }
        
        XCTAssertEqual(urlArray, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let expectedError = anyNSError()

        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.complete(with: expectedError)
        }
    }
    
    func test_loadImageFromDataFromURL_deliversErrorOnNo200HttpResponse() {
        let (client, sut) = makeSUT()
        let error = anyNSError()
        let samples = [199, 201, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(error)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
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
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait for load completion")
        
        sut.loadImageData(url: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                break
            
            case let (.failure(receivedError), .failure(expectedError) ):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)

                break
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyData() -> Data {
        return  Data("any data".utf8)
    }
    
    private class HTTPClienSpy: HTTPClient {

        var receivedMessages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedMessages.append((url,completion))

        }
        
        func complete(with error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data,at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: receivedMessages[index].url,
                                               statusCode: code,
                                               httpVersion: nil,
                                               headerFields: nil)!
            receivedMessages[index].completion(.success((data, httpResponse)))
        }
    }
}
