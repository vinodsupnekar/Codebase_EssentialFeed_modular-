//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
         let feed: [CodableFeedImage]
         let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(_ completion: @escaping FeedStore.RetrievalCompletion ) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.emtpy)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found((feed: cache.localFeed, timestamp: cache.timestamp)))
        
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map { CodableFeedImage($0)}, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()

    }
    
    func test_retrieve_deleiversEmptyOnEmptyCache() {
        let sut = makeSUT()
      
        expect(sut, toCompleteWith: .emtpy)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyache() {
        
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
            switch (firstResult, secondResult) {
            case (.emtpy, .emtpy):
                break
            default:
                XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult)  and \(secondResult) instead")
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_AfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
           
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toCompleteWith: .found((feed, timestamp)))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case let (.found(firstResult), .found(secondResult)):
                    XCTAssertEqual(firstResult.feed, feed)
                    XCTAssertEqual(firstResult.timestamp, timestamp)
                    
                    XCTAssertEqual(secondResult.feed, feed)
                    XCTAssertEqual(secondResult.timestamp, timestamp)
                    break
                default:
                    XCTFail("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
                }
        }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // -MARK:- Helpers
    
    private func expect(_ sut: CodableFeedStore, toCompleteWith expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.emtpy, .emtpy) :
                break
                
            case let (.found(expectedResult), .found(retrieved)):
                XCTAssertEqual(expectedResult.feed, retrieved.feed, file: file, line: line)
                XCTAssertEqual(expectedResult.timestamp, retrieved.timestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        
        
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
    }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
}
