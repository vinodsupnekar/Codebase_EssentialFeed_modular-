//
//  EssentialFeedCacheIntegrayionTests.swift
//  EssentialFeedCacheIntegrayionTests
//
//  Created by Rjvi on 01/04/23.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrayionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()

    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut: sut, toLoad: [])
        
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
        
        expect(sut: sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_OverridesItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models

        save(firstFeed, with: sutToPerformSave)
        save(lastFeed, with: sutToPerformLastSave)

        expect(sut: sutToPerformLoad, toLoad: lastFeed)
    }
    
    
    
    // MARK :- Helpers
    
    private func expect(sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line ){
        let exp = expectation(description: "wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file,line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line:  line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage],with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "wait for save completion")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
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
