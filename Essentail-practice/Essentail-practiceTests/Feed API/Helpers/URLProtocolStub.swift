//
//  URLProtocolStub.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/24.
//

import Foundation
class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data : Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    private static var _stub: Stub?
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var stub: Stub? {
        get { return queue.sync { return _stub }}
        set {queue.sync { _stub = newValue }}
    }
    static func stub(data: Data?, response: URLResponse? ,error: Error?, requestObserver: ((URLRequest) -> Void)?) {
        
        stub = Stub(data: data, response: response,error: error, requestObserver: requestObserver)
    }
    
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil,error: nil, requestObserver: observer)
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
     }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // if request has been observed then there will be no (recieved data, recieved response and error)
        guard let stub = URLProtocolStub.stub else { return }
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
        
        stub.requestObserver?(request)
    }
    
    override func stopLoading() {}
}
