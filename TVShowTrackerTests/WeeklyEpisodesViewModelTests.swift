//
//  WeeklyEpisodesViewModelTests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-15.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class WeeklyEpisodesViewModelTests: XCTestCase {
    
    var sut: WeeklyTVEpisodeListViewModel!
    var apiService: TVMazeAPIService!
    var mockSession: URLSessionMock!
    var dates: [Date]!
    
    override func setUp() {
        
        dates = [Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 86400)]
        mockSession = URLSessionMock()
        apiService = TVMazeAPIService(withSession: mockSession)
        sut = WeeklyTVEpisodeListViewModel(dates: dates, apiService: apiService)
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        dates = nil
        mockSession = nil
        apiService = nil
        sut = nil
    }
    
    
    
}
