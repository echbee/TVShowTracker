//
//  TVMazeAPITests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-14.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class TVMazeAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func loadDataInLocalBundle(fromPath path: String,
                                      fileType:String) -> Data? {
        
        let testBundle = Bundle(for: type(of: self))
        let samplePath = testBundle.path(forResource: path, ofType: fileType)
        let data = try? Data(contentsOf: URL(fileURLWithPath: samplePath!), options: .alwaysMapped)
        
        return data
    }
    
    func testEpisodeScheduleURL() {
        let countryCode = TVMazeAPI.CountryCode.US
        let date = Date.init(timeIntervalSince1970: 0)
        
        let url = TVMazeAPI.episodeScheduleURL(for: countryCode, date: date)
        
        XCTAssert(url != nil)
        XCTAssertEqual(url?.absoluteString, "http://api.tvmaze.com/schedule?country=US&date=1969-12-31")
    }
    
    func testShowCastURL() {
        
        let url = TVMazeAPI.showCastURL(forShowId: 1)
        
        XCTAssert(url != nil)
        XCTAssertEqual(url?.absoluteString, "http://api.tvmaze.com/shows/1/cast")
        
    }
    
    func testParseEpisodesWithShowValidInput() {
        let data = loadDataInLocalBundle(fromPath: "sampleEpisodeWithShowList", fileType: "json")!
        
        let episodesArr = TVMazeAPI.parseEpisodesWithShow(from: data)!
        
        XCTAssertEqual(episodesArr.count, 3)
        XCTAssertEqual(episodesArr[0].id, 1477057)
        XCTAssertEqual(episodesArr[0].name, "06-24-2018")
    }
    
    func testParseShowCastValidInput() {
        let data = loadDataInLocalBundle(fromPath: "sampleShowCast", fileType: "json")!
        
        let showCastArr = TVMazeAPI.parseShowCast(from: data, forShowId: 1)!
        
        XCTAssertEqual(showCastArr.count, 4)
        XCTAssertEqual(showCastArr[0].person.id, 60414)
        XCTAssertEqual(showCastArr[0].character.id, 288162)
    }
    
    func testParseEpisodesWithShowInvalidInput() {
        let data = loadDataInLocalBundle(fromPath: "sampleShowCast", fileType: "json")!
        
        let episodesArr = TVMazeAPI.parseEpisodesWithShow(from: data)
        
        XCTAssertNil(episodesArr)
    }
    
    func testParseShowCastInvalidInput() {
        
        let data = loadDataInLocalBundle(fromPath: "sampleEpisodeWithShowList", fileType: "json")!
        
        let showCastArr = TVMazeAPI.parseShowCast(from: data, forShowId: 1)
        
        XCTAssertNil(showCastArr)
    }
    
}
