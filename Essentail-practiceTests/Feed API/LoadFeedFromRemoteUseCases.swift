//
//  Essentail_practiceTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/7.
//

import XCTest
import Essentail_practice


class LoadFeedFromRemoteUseCases: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{_ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{_ in}
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url,url])


    }
    func test_loadDeliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    func test_loadDeliversErrorOnNon200HttpResponse(){
        let (sut, client) = makeSUT()
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code,data: json ,at: index)
            }
        }
        
    }
    func test_load_deliversErrorOn200HttpResponseWithInvalidJON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJsonData = Data("invalid json data".utf8)
            client.complete(withStatusCode: 200, data: invalidJsonData)
        }
                
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemJSON([])
            client.complete(withStatusCode: 200,data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://a-url.com")!
        )
        let item2 = makeItem(
            id: UUID(),
            description: "some description",
            location: "a location",
            imageURL: URL(string: "https://a-url.com")!
        )
        let items = [item1.model, item2.model]
        let itemsJSON = makeItemJSON([item1.json, item2.json])
        
        expect(sut, toCompleteWithResult: .success(items)) {
            client.complete(withStatusCode: 200,data: itemsJSON)
        }
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://some-url.com")!
        let client = HttpClientSpy()
        var sut : RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://some-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut : RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackFroMemoryLeaks(sut, file: file, line: line)
        trackFroMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error : RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String:Any]()) { prev, e in
            if let value = e.value { prev[e.key] = value}
        }
        return (item, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data{
        let json = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action : ()->Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedItems), .success(expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems, file: file, line: line)
            case let (.failure(recievedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recievedError, expectedError)
            default:
                XCTFail("Expected result:\(expectedResult) but got \(recievedResult) instead", file:file, line: line)
            }
            exp.fulfill()
       }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    
    private class HttpClientSpy : HttpClient {
        private var messages = [(url: URL, completion: (HTTPClientResult)->Void)]()
        var requestedURLs : [URL] {
            return messages.map{$0.url}
        }
        func get(from url: URL, completion : @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code : Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }


}
