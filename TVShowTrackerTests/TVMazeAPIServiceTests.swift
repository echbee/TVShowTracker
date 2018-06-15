//
//  TVMazeAPIServiceTests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-14.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class TVMazeAPIServiceTests: XCTestCase {
    
    var apiService: TVMazeAPIService!
    var mockSession: URLSessionMock!
    
    override func setUp() {
        super.setUp()
        mockSession = URLSessionMock()
        apiService = TVMazeAPIService(withSession: mockSession)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        apiService = nil
        mockSession = nil
    }
    
    func loadDataInLocalBundle(fromPath path: String,
                               fileType:String) -> Data? {
        
        let testBundle = Bundle(for: type(of: self))
        let samplePath = testBundle.path(forResource: path, ofType: fileType)
        let data = try? Data(contentsOf: URL(fileURLWithPath: samplePath!), options: .alwaysMapped)
        
        return data
    }
    
    func testFetchEpisodesForUSForValidResponse() {
        let date = Date.init(timeIntervalSince1970: 0)
        
        let expectedData = loadDataInLocalBundle(fromPath: "sampleEpisodeWithShowList", fileType: "json")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        apiService.fetchEpisodesForUS(on: date) { (result) in
            switch result {
                case .success(let episodesArr):
                    XCTAssertEqual(episodesArr.count, 3)
                case .failure(let error):
                    XCTFail("Failed with error \(error.localizedDescription)")
            }
        }
    }
    
    func testFetchEpisodesForUSForInvalidResponse() {
        let date = Date.init(timeIntervalSince1970: 0)
        
        let expectedData = loadDataInLocalBundle(fromPath: "sampleShowCast", fileType: "json")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        apiService.fetchEpisodesForUS(on: date) { (result) in
            switch result {
            case .success:
                XCTFail("Wrong response received")
            case .failure:
                break
            }
        }
    }
    
    func testFetchCastsForValidResponse() {
        
        let expectedData = loadDataInLocalBundle(fromPath: "sampleShowCast", fileType: "json")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        apiService.fetchCasts(forShow: 1) { (result) in
            switch result {
            case .success(let castsArr):
                XCTAssertEqual(castsArr.count, 4)
            case .failure(let error):
                XCTFail("Failed with error \(error.localizedDescription)")
            }

        }
    }
    
    func testFetchCastsForInvalidResponse() {
        
        let expectedData = loadDataInLocalBundle(fromPath: "sampleEpisodeWithShowList", fileType: "json")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        apiService.fetchCasts(forShow: 1) { (result) in
            switch result {
            case .success:
                XCTFail("Wrong response received")
            case .failure:
                break
            }

        }
        
    }
    
    func testFetchImageWithValidImage() {
        let expectedData = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        let randomURL = URL(string: "RandomURL")!
        apiService.fetchImage(atURL: randomURL) { (result) in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Wrong response received")
            }
            
        }
    }
    
    func testFetchImageWithInvalidImage() {
        let expectedData = loadDataInLocalBundle(fromPath: "sampleShowCast", fileType: "json")!
        
        let expectedResponse = HTTPURLResponseMock.init(withStatusCode: 200)
        
        mockSession.setExpectedResponse(data: expectedData, response: expectedResponse, error: nil)
        
        let randomURL = URL(string: "RandomURL")!
        apiService.fetchImage(atURL: randomURL) { (result) in
            switch result {
            case .success:
                XCTFail("Wrong response received")
            case .failure:
                break
            }
        }
        
    }
    
}
