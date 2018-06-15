//
//  DailyTVEpisodeViewModelTests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-15.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class DailyTVEpisodeViewModelTests: XCTestCase {
    
    var apiService: TVMazeAPIService!
    var mockSession: URLSessionMock!
    
    var sut: DailyTVEpisodeListViewModel!
    
    override func setUp() {
        super.setUp()
        mockSession = URLSessionMock()
        apiService = TVMazeAPIService(withSession: mockSession)
        sut = DailyTVEpisodeListViewModel(date: Date(),
                                          apiService: apiService)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        mockSession = nil
        apiService = nil
    }
    
    func loadSUTWithData() {
        let expectedData = loadDataInLocalBundle(fromPath: "sampleEpisodeWithShowList", fileType: "json")!
        
        mockSession.setExpectedResponse(data: expectedData, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        let future = expectation(description: "Needed to bypass Dispatch Async")
        
        sut.populate { (didChange) in
            XCTAssertEqual(didChange, true)
            future.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func loadDataInLocalBundle(fromPath path: String,
                               fileType:String) -> Data? {
        
        let testBundle = Bundle(for: type(of: self))
        let samplePath = testBundle.path(forResource: path, ofType: fileType)
        let data = try? Data(contentsOf: URL(fileURLWithPath: samplePath!), options: .alwaysMapped)
        
        return data
    }
    
    func testPopulateWithValidData() {
        XCTAssertEqual(sut.isPopulated, false)
        loadSUTWithData()
        
        XCTAssertEqual(sut.count, 3)
    }
    
    func testPopulateWithInvalidData() {
        XCTAssertEqual(sut.isPopulated, false)
        
        let expectedData = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")!
        
        mockSession.setExpectedResponse(data: expectedData, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        let future = expectation(description: "Needed to bypass Dispatch Async")
        
        sut.populate { (didChange) in
            future.fulfill()
            XCTAssertEqual(didChange, false)
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.isPopulated, false)
    }
    
    func testFilterEpisodesWithNonZeroOutputInNetwork() {
        loadSUTWithData()
        
        sut.filterEpisodes(withSearchText: "Syndication", forCategory: .Network)
        
        XCTAssertEqual(sut.count, 2)
        
        sut.clearFilter()
        
        XCTAssertEqual(sut.count, 3)
    }
    
    func testFilterEpisodesWithZeroOutputInNetwork() {
        loadSUTWithData()
        
        sut.filterEpisodes(withSearchText: "blablabla", forCategory: .Network)
        
        XCTAssertEqual(sut.count, 0)
        
        sut.clearFilter()
        
        XCTAssertEqual(sut.count, 3)
    }
    
    func testFilterEpisodesWithNonZeroOutputInShow() {
        loadSUTWithData()
        
        sut.filterEpisodes(withSearchText: "Democracy Now!", forCategory: .Show)
        
        XCTAssertEqual(sut.count, 1)
        
        sut.clearFilter()
        
        XCTAssertEqual(sut.count, 3)
    }
    
    func testFilterEpisodesWithZeroOutputInShow() {
        loadSUTWithData()
        
        sut.filterEpisodes(withSearchText: "blablabla", forCategory: .Show)
        
        XCTAssertEqual(sut.count, 0)
        
        sut.clearFilter()
        
        XCTAssertEqual(sut.count, 3)
    }
    
    func testFilterEpisodesReturnsCorrectEpisodeViewModel() {
        loadSUTWithData()
        
        sut.filterEpisodes(withSearchText: "Disney XD", forCategory: .Network)
        
        XCTAssertEqual(sut.count, 1)
        
        let returnedViewModel = sut.episodeViewModel(atIndex: 0)
        
        XCTAssertEqual(returnedViewModel?.showNetwork, "Disney XD")
        
        sut.clearFilter()
        
        XCTAssertEqual(sut.count, 3)
    }

    
}
