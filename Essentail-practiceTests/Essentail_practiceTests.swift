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
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    func test_loadDeliversErrorOnNon200HttpResponse(){
        let (sut, client) = makeSUT()
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
        
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut : RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HttpClientSpy : HttpClient {
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?)->Void)]()
        var requestedURLs : [URL] {
            return messages.map{$0.url}
        }
        func get(from url: URL, completion : @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        func complete(withStatusCode code : Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)
            messages[index].completion(nil, response)
        }
    }


}
