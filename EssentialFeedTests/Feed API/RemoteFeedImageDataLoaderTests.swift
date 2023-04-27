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
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask

        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return HTTPTaskWrapper(wrapped:client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                } else {
                completion(.failure(RemoteFeedImageDataLoader.Error.invalidData))
                }
            case let .failure(error): completion(.failure(error))
            }
        })
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
        
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.receivedMessages.first?.url, url)
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

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
    
    func test_loadImageDataFromURL_deliversErrorOnNo200HttpResponse() {
        let (client, sut) = makeSUT()
        let samples = [199, 201, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
            let emptyData = Data("".utf8)
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedNoEmptyDataon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
   
        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClienSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var caprturedResult = [FeedImageDataLoader.Result](
        )
        sut?.loadImageData(from: anyURL()) { caprturedResult.append($0)}
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(caprturedResult.isEmpty)
        
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
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                break
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
               XCTAssertEqual(receivedError , expectedError, file: file, line: line)
                
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

        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        var receivedMessages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            receivedMessages.append((url,completion))
            return Task()

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
