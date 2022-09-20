//
//  Essentail_practiceTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/7.
//

import XCTest
import Essentail_practice


class Essentail_practiceTests: XCTestCase {

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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    func test_loadDeliversErrorOnNon200HttpResponse(){
        let (sut, client) = makeSUT()
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
        
    }
    func test_load_deliversErrorOn200HttpResponseWithInvalidJON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJsonData = Data("invalid json data".utf8)
            client.complete(withStatusCode: 200, data: invalidJsonData)
        }
                
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200,data: emptyListJSON)
        }
    }
    
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut : RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action : ()->Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
        func complete(withStatusCode code : Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }


}
