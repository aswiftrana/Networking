//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by Asad Rana on 2/29/20.
//  Copyright © 2020 anrana. All rights reserved.
//

import XCTest
import Combine
@testable import Networking

class NetworkingTests: XCTestCase {
    

    func testNetworkError() {
        let errorExp = expectation(description: "Network error")
        
        let session = URLSession.makeMock()
        URLProtocolMock.action = .error(error: NetworkMockFactory.Error.networkConnectionLost)
        let request: AnyPublisher<Data, ClientError> = Client.init(session: session)
            .get(components: NetworkMockFactory.Components.valid)
        
        let cancellable = request.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion, error == NetworkMockFactory.ClientError.networkConnectionLost {
                errorExp.fulfill()
            }
        }, receiveValue: { _ in })
        
        wait(for: [errorExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved Network error")
        cancellable.cancel()
    }
    
    func testInvalidURLError() {
        let errorExp = expectation(description: "Invalid URL error")
        
        let session = URLSession.makeMock()
        URLProtocolMock.action = .error(error: NetworkMockFactory.Error.networkConnectionLost)
        let request: AnyPublisher<Data, ClientError> = Client.init(session: session)
            .get(components: NetworkMockFactory.Components.invalid)
        
        let cancellable = request.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion, error == .invalidURL {
                errorExp.fulfill()
            }
        }, receiveValue: { _ in })
        
        wait(for: [errorExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved Invalid URL error")
        cancellable.cancel()
    }
    
    func testUnknownError() {
        let errorExp = expectation(description: "Unknown error")
        
        let session = URLSession.makeMock()
        URLProtocolMock.action = .noResponse
        let request: AnyPublisher<Data, ClientError> = Client.init(session: session)
            .get(components: NetworkMockFactory.Components.valid)
        
        let cancellable = request.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion, error == .unknown {
                errorExp.fulfill()
            }
        }, receiveValue: { _ in })
        
        wait(for: [errorExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved Unknown error")
        cancellable.cancel()
    }
    
    func test403Response() {
        let errorExp = expectation(description: "403 response")
        
        let session = URLSession.makeMock()
        URLProtocolMock.action = .response(data: Data(), response: NetworkMockFactory.Response.invalid403)
        let request: AnyPublisher<Data, ClientError> = Client.init(session: session)
            .get(components: NetworkMockFactory.Components.valid)
        
        let cancellable = request.sink(receiveCompletion: { completion in
            if case .failure(let error) = completion, error == .network(code: 403, reason: "forbidden") {
                errorExp.fulfill()
            }
        }, receiveValue: { _ in })
        
        wait(for: [errorExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved 403 response error")
        cancellable.cancel()
    }
    
    func testValidResponse() {
        let responseExp = expectation(description: "Valid response")
        
        let session = URLSession.makeMock()
        let mockCreds = Credentials.mock
        URLProtocolMock.action = .response(data: NetworkMockFactory.Model.data(for: mockCreds),
                                           response: NetworkMockFactory.Response.valid)
        let request: AnyPublisher<Credentials, ClientError> = Client.init(session: session)
            .getAndDecode(components: NetworkMockFactory.Components.valid)
        
        let cancellable = request.sink(receiveCompletion: { _ in
            // skip
        }, receiveValue: { creds in
            if creds == mockCreds {
                responseExp.fulfill()
            }
        })
        
        wait(for: [responseExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved valid response")
        cancellable.cancel()
    }
    
    func testDecodingError() {
        let errorExp = expectation(description: "Decoding error")

        let session = URLSession.makeMock()
        URLProtocolMock.action = .response(data: NetworkMockFactory.Model.data(for: MalFormedCredentials.mock),
                                           response: NetworkMockFactory.Response.valid)
        let request: AnyPublisher<Credentials, ClientError> = Client.init(session: session)
            .getAndDecode(components: NetworkMockFactory.Components.valid)
        
        let cancellable = request.sink(receiveCompletion: { completion in
           if case .failure(let error) = completion, case .decoding(_) = error {
               errorExp.fulfill()
           }
        }, receiveValue: { _ in })
        
        wait(for: [errorExp], timeout: 2)
        
        XCTAssertTrue(true, "Recieved Decoding error")
        cancellable.cancel()
    }
    
    private struct Credentials: Codable, Equatable {
        let username: String
        let password: String
        
        static let mock = Credentials.init(username: "user", password: "1234")
    }
    
    private struct MalFormedCredentials: Codable, Equatable {
        let username: String
        
        static let mock = MalFormedCredentials.init(username: "user")
    }
}
