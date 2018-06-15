//
//  TVEpisodeViewModelTests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-15.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class TVEpisodeViewModelTests: XCTestCase {
    
    var apiServiceMock: TVMazeAPIService!
    var mockSession: URLSessionMock!
    
    var dummyEpisode: TVEpisode {
        let dummyEpisode = TVEpisode(id: 1,
                                     name: "sampleEpisode",
                                     seasonNumber: 11,
                                     number: 2,
                                     airDate: ISO8601DateFormatter().date(from: "2018-06-25T05:30:00+00:00")!,
                                     duration: 30,
                                     showId: 26,
                                     thumbnailURL: URL(string: "http://someThumbnailURL"),
                                     imageURL: URL(string: "http://someThumbnailURL"),
                                     summary: "someSummary",
                                     show: nil)
        return dummyEpisode
    }
    
    var dummyShow: TVShow {
        let dummyShow = TVShow(id: 1,
                               name: "someShow",
                               genres: [],
                               networkName: "someNetwork",
                               timezone: TimeZone(identifier: "America/New_York")!,
                               thumbnailURL: URL(string: "http://someThumbnailURL")!,
                               imageURL: URL(string: "http://someImageURL")!,
                               summary: "someSummary")
        return dummyShow
    }
    
    override func setUp() {
        mockSession = URLSessionMock()
        apiServiceMock = TVMazeAPIService(withSession: mockSession)
        
        super.setUp()
    }
    
    override func tearDown() {

        super.tearDown()
        mockSession = nil
        apiServiceMock = nil
    }
    
    func loadDataInLocalBundle(fromPath path: String,
                               fileType:String) -> Data? {
        
        let testBundle = Bundle(for: type(of: self))
        let samplePath = testBundle.path(forResource: path, ofType: fileType)
        let data = try? Data(contentsOf: URL(fileURLWithPath: samplePath!), options: .alwaysMapped)
        
        return data
    }
    
    func testParametersWithValidEpisodeWithShow() {
        
        let episode = dummyEpisode
        episode.show = dummyShow
        
        let sut = TVEpisodeViewModel(episode: episode,
                                     apiService: apiServiceMock)
        
        XCTAssertEqual(sut.episodeName, dummyEpisode.name)
        XCTAssertEqual(sut.showName, dummyShow.name)
        XCTAssertEqual(sut.showNetwork, dummyShow.networkName)
        XCTAssertEqual(sut.startTime, "1:30 AM")
    }
    
    func testParametersWithValidEpisodeWithoutShow() {
        
        let sut = TVEpisodeViewModel(episode: dummyEpisode,
                                     apiService: apiServiceMock)
        
        XCTAssertEqual(sut.episodeName, dummyEpisode.name)
        XCTAssertEqual(sut.showName, "")
        XCTAssertEqual(sut.startTime, "")
    }
    
    func testFetchShowThumbnailWithThumbnailImage() {
        
        let episode = dummyEpisode
        episode.show = dummyShow
        
        let data = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        let sut = TVEpisodeViewModel(episode: episode,
                                     apiService: apiServiceMock)
        
        mockSession.setExpectedResponse(data: data!, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowThumbnail { (fetchedImage) in
            XCTAssertNotNil(fetchedImage)

            XCTAssertEqual(self.mockSession.url!, self.dummyShow.thumbnailURL!)
        }
        
    }
    
    func testFetchShowThumbnailWithFullImage() {
        
        let episode = dummyEpisode
        
        let nilThumbnailShow = TVShow(id: 1,
                               name: "someShow",
                               genres: [],
                               networkName: "someNetwork",
                               timezone: TimeZone(identifier: "America/New_York")!,
                               thumbnailURL: nil,
                               imageURL: URL(string: "http://someImageURL")!,
                               summary: "someSummary")
        episode.show = nilThumbnailShow
        
        let data = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        let sut = TVEpisodeViewModel(episode: episode,
                                     apiService: apiServiceMock)
        
        mockSession.setExpectedResponse(data: data!, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowThumbnail { (fetchedImage) in
            XCTAssertNotNil(fetchedImage)
            
            XCTAssertEqual(self.mockSession.url!, nilThumbnailShow.imageURL!)
        }
        
    }
    
    func testFetchShowThumbnailWithNilImage() {
        
        let episode = dummyEpisode
        
        let nilImageShow = TVShow(id: 1,
                                      name: "someShow",
                                      genres: [],
                                      networkName: "someNetwork",
                                      timezone: TimeZone(identifier: "America/New_York")!,
                                      thumbnailURL: nil,
                                      imageURL: nil,
                                      summary: "someSummary")
        episode.show = nilImageShow
        
        let data = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        let sut = TVEpisodeViewModel(episode: episode,
                                     apiService: apiServiceMock)
        
        mockSession.setExpectedResponse(data: data!, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowThumbnail { (fetchedImage) in
            XCTAssertNil(fetchedImage)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
