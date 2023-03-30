//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/03/23.
//

import XCTest
import EssentialFeed

protocol FeedStoreSpecs {
     func test_retrieve_deleiversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectsOnEmptyache()
     func test_retrieve_deliversFoundValueOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
     func test_insert_deliversNoErrorOnEmptyCache()
     func test_insert_deliversNoErrorOnNonEmptyCache()
     func test_insert_overridesPrevioslyInsertedData()
    
     func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
     func test_delete_hasNoSideEffectsOnEmptyCache()
     func test_delete_emptiesPreviouslyInsertedCache()
    
     func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpec {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpec {
    func test_insert_deliversErrorOnInsertionError()
}

protocol FailableDeleteFeedStoreSpec {
    func test_delete_deleiversErrorOnDeletionError()
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
      
        expect(sut, toRetrieve: .emtpy)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyache() {
        let sut = makeSUT()
        
        self.expect(sut, toRetrieveTwice: .emtpy)
        self.expect(sut, toRetrieveTwice: .emtpy)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found((feed, timestamp)))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found((feed, timestamp)))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
       
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
       
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPrevioslyInsertedData() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found((feed: feed, timestamp: timestamp)))
    }
    
    func test_insert_hasNoSideEffectsByOverridingPrevioslyInsertedData() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let firstInsertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        let latestInsertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found((feed, timestamp)))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .emtpy)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .emtpy)
    }
    
    func test_delete_deleiversErrorOnDeletionError() {
        let noDeletePermissinURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissinURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Opearation 1")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Opearation 2")
        sut.deleteCacheFeed { _ in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Opearation 3")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(completedOperationInOrder, [op1, op2, op3], "Expected side effects to run serially but operations finished in the wrong order")
    }
    
    // -MARK:- Helpers
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date) ,to sut: FeedStore) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(cache.feed, timeStamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "wait for cache deletion")
        sut.deleteCacheFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.emtpy, .emtpy),
                 (.failure, .failure):
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
    
    private func makeSUT( storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of:self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
