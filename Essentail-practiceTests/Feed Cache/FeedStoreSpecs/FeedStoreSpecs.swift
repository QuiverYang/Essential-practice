//
//  FeedStoreSpecs.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/12/2.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieveA_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertionValues()

    func test_delete_hasNoSideEffectOnEmptyCache()
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs : FeedStoreSpecs{
    func test_retrieve_deliversFailureOnRetrivalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailabelInsertFeedStoreSpecs : FeedStoreSpecs{
    func test_insert_deliversErrorInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailabelDeleteFeedStoreSpecs : FeedStoreSpecs{
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailabelDeleteFeedStoreSpecs & FailableRetrieveFeedStoreSpecs & FailabelInsertFeedStoreSpecs
