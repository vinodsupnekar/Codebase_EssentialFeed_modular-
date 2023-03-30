//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 30/03/23.
//

import Foundation

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

protocol FailableRetrieveFeedStoreSpec: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpec: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
}

protocol FailableDeleteFeedStoreSpec: FeedStoreSpecs {
    func test_delete_deleiversErrorOnDeletionError()
}
