//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 09/02/23.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversOnClientError() {
        let (sut, client) = makeSUT()
        
        self.expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        }
    }
    
    func test_load_deliversErrorOnNon200ttptResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index,code in
            self.expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code, data: json,at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        self.expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        self.expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON =  makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200ResponseWithJSONItem() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedImage(id: UUID(), description: nil, location: nil, url: URL(string:"http://a-url.com")!)
        
        let item1JSON = [
            "id" : item1.id.uuidString,
            "image": item1.url.absoluteString
        ]
                
        let item2 = FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string:"http://another-url.com")!)
        
        let item2JSON = [
            "id" : item2.id.uuidString,
            "image": item2.url.absoluteString,
            "description": item2.description,
            "location": item2.location
        ]
        
        expect(sut, toCompleteWith:.success([item1, item2])) {
            let json = makeItemJSON([item1JSON, item2JSON as [String : Any]])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string:"http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK:- Helpers
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-given.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        
     return (sut, client)
    }
    
    private func makeFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        let feedItem = FeedImage(id: id, description: description, location: location, url: imageURL)
        _ = [
            "id" : feedItem.id.uuidString,
            "image": feedItem.url.absoluteString,
            "description": feedItem.description,
            "location": feedItem.location
        ].compactMapValues { $0 }
    }
    
    private func makeItemJSON(_ item: [[String: Any]]) -> Data {
        let itemJSON = [
            "items": item]
            return try! JSONSerialization.data(withJSONObject: itemJSON)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedReslut: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load comppletion")
        sut.load { receivedResult in
            switch (receivedResult, expectedReslut){
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error),.failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                 XCTFail("Expected result \(expectedReslut), but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        var error: Error?
        private var messages = [(url: URL, completion: (HTTPClient.Result)->Void)]()
         
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data ,at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
